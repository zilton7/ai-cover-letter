require 'rails_helper'
require 'stripe_mock'

RSpec.describe 'Checkout System', type: :system, js: true do
  login_user

  let(:stripe_session_url) { 'https://checkout.stripe.com/session_123' }

  let(:stripe_checkout_session) do
    double(Stripe::Checkout::Session,
           id: 'cs_test_123',
           url: stripe_session_url,
           payment_status: 'paid')
  end

  let(:stripe_subscription) do
    double(Stripe::Subscription,
           id: 'sub_123',
           status: 'canceled')
  end

  let(:event) do
    Stripe::Event.construct_from(
      id: 'evt_123',
      type: 'checkout.session.completed',
      data: {
        object: {
          id: stripe_checkout_session.id,
          payment_status: 'paid',
          customer: 'cus_123',
          subscription: 'sub_123'
        }
      }
    )
  end

  let(:stripe_event_payload) do
    {
      id: 'evt_123',
      type: 'checkout.session.completed',
      data: {
        object: {
          id: stripe_checkout_session.id,
          payment_status: 'paid',
          customer_email: @user.email,
          subscription: 'sub_123',
          metadata: {
            plan: 'turbo_premium'
          }
        }
      }
    }.to_json
  end

  before do
    stub_const('STRIPE_PLANS', { premium: { id: 'price_124', price: 277 },
                                 turbo_premium: { id: 'price_123', price: 577 } })
    allow(Stripe::Checkout::Session).to receive(:create).and_return(stripe_checkout_session)

    allow(Stripe::Webhook).to receive(:construct_event).and_return(
      Stripe::Event.construct_from(JSON.parse(stripe_event_payload))
    )
  end

  describe 'subscription flow' do
    before(:each) do
      StripeMock.start
    end

    after(:each) do
      StripeMock.stop
    end

    it 'allows user to start a subscription' do
      visit subscriptions_path

      find('#turbo_premium').click
      expect(page).to have_current_path(stripe_session_url, url: true)

      event = StripeMock.mock_webhook_event('checkout.session.completed', {
                                              id: 'cs_test_123',
                                              payment_status: 'paid',
                                              customer_email: @user.email,
                                              subscription: 'sub_123',
                                              metadata: {
                                                plan: 'turbo_premium'
                                              }
                                            })
      StripeEvent.instrument(event)

      expect(@user.subscription).to be_present

      visit success_checkout_index_path

      expect(page).to have_content('Subscription successful!')
      expect(page.current_path).to eq(root_path)
    end

    context 'when subscription is canceled during checkout' do
      let(:subscription) { create(:subscription, user: @user) }

      it 'shows cancellation message' do
        event = StripeMock.mock_webhook_event('invoice.payment_failed', {
                                                id: 'cs_test_123',
                                                payment_status: 'payment_failed',
                                                customer_email: @user.email,
                                                subscription: subscription.stripe_subscription_id,
                                                metadata: {
                                                  plan: 'turbo_premium'
                                                }
                                              })
        StripeEvent.instrument(event)

        visit cancel_checkout_index_path

        expect(page).to have_content('Subscription canceled.')
        expect(page.current_path).to eq(root_path)
        expect(@user.subscription.status).to eq('payment_failed')
      end
    end
  end

  describe 'invoice.payment_failed webhook' do
    let!(:subscription) do
      create(:subscription,
             user: @user,
             stripe_subscription_id: 'sub_123',
             status: 'active')
    end

    it 'updates the subscription status to payment_failed' do
      # Start StripeMock
      StripeMock.start

      # Create a mock webhook event for 'invoice.payment_failed'
      event = StripeMock.mock_webhook_event('invoice.payment_failed', {
                                              id: 'in_123',
                                              subscription: subscription.stripe_subscription_id
                                            })

      # Simulate Stripe sending a webhook event
      StripeEvent.instrument(event)

      # Verify the subscription status was updated
      subscription.reload
      expect(subscription.status).to eq('payment_failed')

      # Stop StripeMock
      StripeMock.stop
    end
  end

  describe 'customer.subscription.deleted webhook' do
    let!(:subscription) do
      create(:subscription,
             user: @user,
             stripe_subscription_id: 'sub_123',
             status: 'active')
    end

    it 'updates the subscription status to canceled' do
      StripeMock.start

      event = StripeMock.mock_webhook_event('customer.subscription.deleted', {
                                              id: subscription.stripe_subscription_id
                                            })

      StripeEvent.instrument(event)

      subscription.reload
      expect(subscription.status).to eq('canceled')

      StripeMock.stop
    end
  end

  describe 'authentication' do
    it 'requires login for subscription actions' do
      logout
      visit subscriptions_path

      expect(page.current_path).to eq(new_user_session_path)
      expect(page).to have_content('You need to sign in or sign up before continuing.')
    end
  end

  describe 'subscription cleanup' do
    let!(:active_subscription) { create(:subscription, user: @user, status: 'active') }
    let!(:canceled_subscription) { create(:subscription, user: @user, status: 'canceled') }

    it 'cleans up old subscriptions after successful checkout' do
      expect do
        visit success_checkout_index_path
      end.to change { @user.subscriptions.count }.by(-1)

      expect(active_subscription.reload).to be_present
      expect { canceled_subscription.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
