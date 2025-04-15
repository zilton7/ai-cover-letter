Stripe.api_key = Rails.application.credentials.dig(:stripe, :restricted_key)
StripeEvent.signing_secret = Rails.application.credentials.dig(:stripe, :signing_secret)

STRIPE_PLANS = {
  premium: {
    id: 'price_1RE8M7CrHIUGY6dG80EdLS7h', # Replace with your Stripe Price ID
    name: 'Unlimited',
    description: 'Using Groq AI 🚀',
    price: 277,
    most_popular: false
  },
  turbo_premium: {
    id: 'price_1RE8KvCrHIUGY6dGzwCcfvyP', # Replace with your Stripe Price ID
    name: 'Turbo Unlimited',
    description: 'Using GPT-4 🤖',
    price: 577,
    most_popular: true
  }
}.freeze
