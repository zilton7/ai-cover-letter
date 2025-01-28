class CheckoutController < ApplicationController
  before_action :authenticate_user!

  def create
    plan = STRIPE_PLANS[params[:plan].to_sym]

    begin
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
    rescue Stripe::StripeError => e
      Rails.logger.error("Stripe error: #{e.message}")
      redirect_to root_path, alert: "There was an issue creating your subscription: #{e.message}"
    rescue StandardError => e
      Rails.logger.error("Unexpected error: #{e.message}")
      redirect_to root_path, alert: 'An unexpected error occurred. Please try again.'
    end
  end

  def cancel_subscription
    subscription = current_user.subscription

    return redirect_to root_path, alert: 'No active subscription found.' if subscription.nil?

    begin
      # Immediately cancel the subscription in Stripe
      Stripe::Subscription.cancel(subscription.stripe_subscription_id)

      # Update local subscription status
      subscription.update(status: 'canceled')

      redirect_to root_path, notice: 'Your subscription has been canceled.'
    rescue Stripe::StripeError => e
      Rails.logger.error("Stripe error while canceling subscription: #{e.message}")
      redirect_to root_path, alert: "Error canceling subscription: #{e.message}"
    rescue StandardError => e
      Rails.logger.error("Unexpected error while canceling subscription: #{e.message}")
      redirect_to root_path, alert: 'An unexpected error occurred while canceling your subscription. Please try again.'
    end
  end

  def success
    current_user.subscriptions.each do |subscription|
      subscription.destroy unless subscription.status == 'active'
    end

    flash[:notice] = 'Subscription successful!'
    redirect_to root_path
  end

  def cancel
    flash[:alert] = 'Subscription canceled.'
    redirect_to root_path
  end
end
