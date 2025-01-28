require 'rails_helper'

RSpec.describe 'Checkout', type: :request do
  login_user

  # Mock Stripe responses
  let(:stripe_checkout_session) do
    double(Stripe::Checkout::Session,
           id: 'cs_test_123',
           url: 'https://checkout.stripe.com/pay/cs_test_123',
           payment_status: 'paid')
  end

  describe 'POST #create' do
    let(:plan_id) { 'price_123' }

    before do
      stub_const('STRIPE_PLANS', {
                   premium: { id: plan_id }
                 })
    end

    context 'when successful' do
      before do
        allow(Stripe::Checkout::Session).to receive(:create).and_return(stripe_checkout_session)
      end

      it 'creates a checkout session with correct parameters' do
        expect(Stripe::Checkout::Session).to receive(:create).with(
          hash_including(
            payment_method_types: ['card'],
            line_items: [{ price: plan_id, quantity: 1 }],
            mode: 'subscription',
            success_url: success_checkout_index_url,
            cancel_url: cancel_checkout_index_url,
            customer_email: @user.email,
            metadata: { plan: 'premium' }
          )
        )

        post checkout_index_path, params: { plan: 'premium' }
      end

      it 'redirects to stripe checkout url' do
        post checkout_index_path, params: { plan: 'premium' }

        expect(response).to redirect_to(stripe_checkout_session.url)
      end
    end

    context 'when stripe raises an error' do
      before do
        allow(Stripe::Checkout::Session).to receive(:create)
          .and_raise(Stripe::StripeError.new('Stripe API Error'))
      end

      it 'handles the error appropriately' do
        post checkout_index_path, params: { plan: 'premium' }

        expect(flash[:alert]).to be_present
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user is not authenticated' do
      before { sign_out @user }

      it 'redirects to login page' do
        post checkout_index_path, params: { plan: 'premium' }

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE #cancel_subscription' do
    let(:subscription) do
      create(:subscription, plan: 'turbo_premium', user: @user,
                            stripe_subscription_id: 'sub_123', status: 'active')
    end
    let(:stripe_subscription) { double(Stripe::Subscription, id: 'sub_123', status: 'canceled') }

    context 'with an active subscription' do
      before do
        allow(@user).to receive(:subscription).and_return(subscription)
        allow(Stripe::Subscription).to receive(:cancel).and_return(stripe_subscription)
      end

      it 'cancels the subscription' do
        expect(Stripe::Subscription).to receive(:cancel).with('sub_123')

        delete cancel_subscription_checkout_index_path
      end

      it 'updates the local subscription status' do
        delete cancel_subscription_checkout_index_path

        expect(subscription.reload.status).to eq('canceled')
      end

      it 'redirects with success message' do
        delete cancel_subscription_checkout_index_path

        expect(flash[:notice]).to eq('Your subscription has been canceled.')
        expect(response).to redirect_to(root_path)
      end
    end

    context 'without an active subscription' do
      before do
        allow(@user).to receive(:subscription).and_return(nil)
      end

      it 'redirects with error message' do
        delete cancel_subscription_checkout_index_path

        expect(flash[:alert]).to eq('No active subscription found.')
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when stripe cancellation fails' do
      before do
        allow(@user).to receive(:subscription).and_return(subscription)
        allow(Stripe::Subscription).to receive(:cancel)
          .and_raise(Stripe::StripeError.new('Cancellation failed'))
      end

      it 'handles the error appropriately' do
        delete cancel_subscription_checkout_index_path

        expect(flash[:alert]).to eq('Error canceling subscription: Cancellation failed')
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET #success' do
    let!(:active_subscription) { create(:subscription, user: @user, status: 'active') }
    let!(:inactive_subscription) { create(:subscription, user: @user, status: 'canceled') }

    it 'cleans up inactive subscriptions' do
      expect do
        get success_checkout_index_path
      end.to change { @user.subscriptions.count }.by(-1)
    end

    it 'keeps active subscriptions' do
      get success_checkout_index_path

      expect(active_subscription.reload).to be_present
    end

    it 'sets success notice' do
      get success_checkout_index_path

      expect(flash[:notice]).to eq('Subscription successful!')
    end

    it 'redirects to root path' do
      get success_checkout_index_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET #cancel' do
    it 'sets cancellation notice' do
      get cancel_checkout_index_path

      expect(flash[:alert]).to eq('Subscription canceled.')
    end

    it 'redirects to root path' do
      get cancel_checkout_index_path

      expect(response).to redirect_to(root_path)
    end
  end
end
