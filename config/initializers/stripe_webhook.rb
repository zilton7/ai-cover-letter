StripeEvent.configure do |events|
  # Handle successful subscription payments
  events.subscribe 'checkout.session.completed', lambda { |event|
    session = event.data.object
    user = User.find_by(email: session.customer_email)
    if user
      Subscription.create!(
        user: user,
        stripe_subscription_id: session.subscription,
        plan: session.metadata.plan,
        status: 'active'
      )
    end
  }

  # Handle failed subscription payments
  events.subscribe 'invoice.payment_failed', lambda { |event|
    invoice = event.data.object
    subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)

    # Update the subscription status to indicate payment failure
    subscription&.update(status: 'payment_failed')
  }

  # Handle subscription cancellation
  events.subscribe 'customer.subscription.deleted', lambda { |event|
    subscription = event.data.object
    user_subscription = Subscription.find_by(stripe_subscription_id: subscription.id)

    # Update the subscription status to indicate cancellation
    user_subscription&.update(status: 'canceled')
  }
end
