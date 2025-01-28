FactoryBot.define do
  factory :job do
    association :user
    title { 'MyJob' }
    company { 'MyJobCompany' }
    location { 'Remote' }
    description { 'MyJobDescription' }

    # Create associated resume
    after(:build) do |job|
      job.resume ||= build(:resume, job: job)
    end

    trait :with_cover_letter do
      after(:build) do |job|
        create_list(:cover_letter, 1, job:)
      end
    end
  end
end
