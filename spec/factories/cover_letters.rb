FactoryBot.define do
  factory :cover_letter do
    association :job
    body { 'This is the content created by FactoryBot' }
    created_at { Time.now }
  end
end
