FactoryBot.define do
  factory :subscription do
    association :user
    stripe_subscription_id { "sub_#{SecureRandom.hex(10)}" }
    status { 'active' }
    plan { 'created by FactoryBot' }
  end
end
