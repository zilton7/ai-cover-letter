Stripe.api_key = Rails.application.credentials.dig(:stripe, :restricted_key)
StripeEvent.signing_secret = Rails.application.credentials.dig(:stripe, :signing_secret)

premium_plan_id = Rails.application.credentials.dig(:stripe, :premium_plan_id)
turbo_premium_plan_id = Rails.application.credentials.dig(:stripe, :turbo_premium_plan_id)

STRIPE_PLANS = {
  premium: {
    id: premium_plan_id, # Replace with your Stripe Price ID
    name: 'Unlimited',
    description: 'Using Groq AI 🚀',
    price: 277,
    most_popular: false
  },
  turbo_premium: {
    id: turbo_premium_plan_id, # Replace with your Stripe Price ID
    name: 'Turbo Unlimited',
    description: 'Using GPT-4 🤖',
    price: 577,
    most_popular: true
  }
}.freeze
