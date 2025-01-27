StripeEvent.configure do |events|
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
end
