Stripe.api_key = Rails.application.credentials.dig(:stripe, :restricted_key)
StripeEvent.signing_secret = Rails.application.credentials.dig(:stripe, :signing_secret)

STRIPE_PLANS = {
  premium: {
    id: 'price_1Qlv4yCrHIUGY6dGoN7pPEF9', # Replace with your Stripe Price ID
    name: 'Unlimited',
    description: 'Using Groq AI 🚀',
    price: 277,
    most_popular: false
  },
  turbo_premium: {
    id: 'price_1Qlv6jCrHIUGY6dGpikCCVw8', # Replace with your Stripe Price ID
    name: 'Turbo Unlimited',
    description: 'Using GPT-4 🤖',
    price: 577,
    most_popular: true
  }
}.freeze
