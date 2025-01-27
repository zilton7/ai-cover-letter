Stripe.api_key = Rails.application.credentials.dig(:stripe, :restricted_key)
StripeEvent.signing_secret = Rails.application.credentials.dig(:stripe, :signing_secret)

STRIPE_PLANS = {
  premium: {
    id: 'price_1Qlv4yCrHIUGY6dGoN7pPEF9', # Replace with your Stripe Price ID
    name: 'Unlimited Subscription',
    price: 277 # $10.00 in cents
  },
  turbo_premium: {
    id: 'price_1Qlv6jCrHIUGY6dGpikCCVw8', # Replace with your Stripe Price ID
    name: 'Turbo Unlimited Subscription',
    price: 577 # $20.00 in cents
  }
}.freeze
