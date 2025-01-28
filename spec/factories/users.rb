FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@test.com" }
    password { '123456' }
    password_confirmation { '123456' }
    credits { 4 }

    after(:build) do |user|
      create_list(:subscription, 1, user:)
    end

    trait :with_job do
      after(:build) do |user|
        user.jobs << build(:job, user:)
      end
    end
  end
end
