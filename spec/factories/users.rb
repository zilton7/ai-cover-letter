FactoryBot.define do
  factory :user do
    email { 'user1@test.com' }
    password { '123456' }
    password_confirmation { '123456' }

    trait :with_job do
      after(:build) do |user|
        user.jobs << build(:job, user:)
      end
    end
  end
end
