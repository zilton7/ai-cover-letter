FactoryBot.define do
  factory :job do
    title { 'MyJob' }
    company { 'MyJobCompany' }
    location { 'Remote' }
    description { 'MyJobCompany' }
    
    # Create associated resume
    after(:build) do |job|
      job.resume ||= build(:resume, job: job)
    end
  end
end
