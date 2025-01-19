FactoryBot.define do
  factory :resume do
    association :job
    label { 'MyString' }
    content { 'This is resume for test' }

    # Attach a PDF file to the `file` attribute
    after(:build) do |resume|
      resume.file.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'resume_for_test.pdf')),
        filename: 'sample_resume.pdf',
        content_type: 'application/pdf'
      )
    end
  end
end
