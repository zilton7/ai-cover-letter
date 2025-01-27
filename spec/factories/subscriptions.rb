FactoryBot.define do
  factory :subscription do
    user { nil }
    stripe_subscription_id { "MyString" }
    plan { "MyString" }
    status { "MyString" }
  end
end
