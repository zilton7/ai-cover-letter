class CheckoutController < ApplicationController
  before_action :authenticate_user!

  def create
    plan = STRIPE_PLANS[params[:plan].to_sym]
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price: plan[:id],
        quantity: 1
      }],
      mode: 'subscription',
      success_url: success_checkout_index_url,
      cancel_url: cancel_checkout_index_url,
      customer_email: current_user.email,
      metadata: {
        plan: params[:plan] # Pass the plan name as metadata
      }
    )

    redirect_to session.url, allow_other_host: true
  end

  def cancel_subscription
    subscription = current_user.subscription
    return redirect_to root_path, alert: 'No active subscription found.' unless subscription

    # Immediately cancel the subscription
    Stripe::Subscription.cancel(subscription.stripe_subscription_id)

    # Update local subscription status
    subscription.update(
      status: 'canceled'
    )

    redirect_to root_path, notice: 'Your subscription has been canceled.'
  rescue Stripe::StripeError => e
    redirect_to root_path, alert: "Error canceling subscription: #{e.message}"
  end

  def success
    current_user.subscriptions.map { |subscription| subscription.destroy unless subscription.status == 'active' }
    # Handle successful subscription
    flash[:notice] = 'Subscription successful!'
    redirect_to root_path
  end

  def cancel
    # Handle canceled subscription
    flash[:alert] = 'Subscription canceled.'
    redirect_to root_path
  end
end
