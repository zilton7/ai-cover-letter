require 'rails_helper'

RSpec.describe 'Checkout System', type: :system, js: true do
  WebMock.stub_request(:any, /.*/).to_return(lambda do |request|
    puts "WebMock received request: #{request.uri}"
    if ['127.0.0.1', 'localhost'].include?(request.uri.host)
      { status: 200, body: 'OK' } # Allow localhost requests
    else
      puts "WebMock blocked request: #{request.uri}"
      { status: 403, body: 'Blocked by WebMock' } # Block external requests
    end
  end)

  login_user

  let(:stripe_checkout_session) do
    double(Stripe::Checkout::Session,
           id: 'cs_test_123',
           url: 'https://checkout.stripe.com/pay/cs_test_123',
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

  before do
    stub_const('STRIPE_PLANS', { premium: { id: 'price_124', price: 277 },
                                 turbo_premium: { id: 'price_123', price: 577 } })
    allow(Stripe::Checkout::Session).to receive(:create).and_return(stripe_checkout_session)
    allow(Stripe::Webhook).to receive(:construct_event).and_return(event)
  end

  describe 'subscription flow' do
    it 'allows user to start a subscription' do
      visit subscriptions_path

      find('#turbo_premium').click

      # Simulate being redirected to Stripe
      visit stripe_checkout_session.url

      # Simulate returning from Stripe after successful payment
      visit success_checkout_index_path

      expect(page).to have_content('Subscription successful!')
      expect(@user.subscription).to be_present
    end

    context 'when subscription is successful' do
      it 'shows success message after returning from Stripe' do
        visit success_checkout_index_path

        expect(page).to have_content('Subscription successful!')
        expect(page.current_path).to eq(root_path)
      end
    end

    context 'when subscription is canceled during checkout' do
      it 'shows cancellation message' do
        visit cancel_checkout_index_path

        expect(page).to have_content('Subscription canceled.')
        expect(page.current_path).to eq(root_path)
      end
    end
  end

  describe 'subscription management' do
    let!(:subscription) do
      create(:subscription,
             plan: 'premium',
             user: @user,
             stripe_subscription_id: 'sub_123',
             status: 'active')
    end

    before do
      allow(Stripe::Subscription).to receive(:cancel).and_return(stripe_subscription)
    end

    it 'allows user to cancel subscription' do
      visit account_path # Assuming you have an account management page

      within '#subscription-section' do # Assuming you have a subscription section
        accept_confirm do
          click_button 'Cancel Subscription'
        end
      end

      expect(page).to have_content('Your subscription has been canceled.')
      expect(subscription.reload.status).to eq('canceled')
    end

    context 'when cancellation fails' do
      before do
        allow(Stripe::Subscription).to receive(:cancel)
          .and_raise(Stripe::StripeError.new('Cancellation failed'))
      end

      it 'shows error message' do
        visit account_path

        within '#subscription-section' do
          accept_confirm do
            click_button 'Cancel Subscription'
          end
        end

        expect(page).to have_content('Error canceling subscription: Cancellation failed')
      end
    end
  end

  describe 'authentication' do
    it 'requires login for subscription actions' do
      visit checkout_index_path

      within '#premium-plan' do
        click_button 'Subscribe'
      end

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
