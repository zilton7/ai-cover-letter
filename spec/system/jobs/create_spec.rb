require 'rails_helper'

RSpec.describe 'Jobs create', type: :system, js: true do
  login_user

  let(:valid_attributes) do
    {
      title: 'Regional co-manager',
      company: 'Dunder Mifflin inc.',
      location: 'Scranton, PA',
      description: 'Dunder Mifflin Paper Company, Inc. is a fictional paper and office supplies wholesale compan.',
      resume_attributes: {
        file: fixture_file_upload(Rails.root.join('spec/fixtures/files/resume_for_test.pdf'), 'application/pdf')
      }
    }
  end

  let(:invalid_attributes) do
    {
      title: '',
      company: '',
      location: '',
      description: '',
      resume_attributes: {
        file: nil
      }
    }
  end

  describe 'Job creation' do
    require 'sidekiq/testing'
    Sidekiq::Testing.inline! # Makes Sidekiq run jobs immediately

    let(:replacements) do
      {
        job_title: valid_attributes[:title],
        resume: 'This is the resume content from pdf file!',
        job_description: valid_attributes[:description],
        company: valid_attributes[:company]
      }.to_json
    end

    let(:mocked_prompt) do
      "Dear Hiring Manager,\n\nI am excited to apply for the Software Engineer position at Tech Corp. \
      With experience in Ruby on Rails, React, and Postgres, I am confident in my ability to contribute \
      to your team's success.\n\nSincerely,\nCandidate Name"
    end

    let(:mocked_groq_ai_api_response) do
      { 'choices': [{ 'message': { 'content': 'This is the content' } }] }.with_indifferent_access
    end

    context 'when the form is valid' do
      it 'creates a new job and displays the modal' do
        allow(PromptGenerator).to receive(:generate)
          .with(replacements)
          .and_return(mocked_prompt)

        # Mock the service
        service = instance_double(GroqAiApiService, call: mocked_groq_ai_api_response)
        allow(GroqAiApiService).to receive(:new).with(mocked_prompt).and_return(service)

        visit new_job_path

        fill_in 'Job Title', with: valid_attributes[:title]
        fill_in 'Company Name', with: valid_attributes[:company]
        fill_in 'Location', with: valid_attributes[:location]
        fill_in 'Job Description', with: valid_attributes[:description]
        # Attach the file to the hidden file input and trigger the change event
        file_path = valid_attributes[:resume_attributes][:file].path
        attach_file('resume-file-upload', file_path, visible: false)
        page.execute_script("document.getElementById('resume-file-upload').dispatchEvent(new Event('change'));")
        # Verify the label update
        expect(page).to have_content("'#{file_path.gsub!('/tmp/', '')}' selected")

        click_button 'Generate Cover Letter'
        expect(page).to have_selector('#turbo-modal')

        expect(page).to have_css('img.animate-pulse[src*="loading"][width="100"][height="100"]', wait: 5)
        expect(Job.count).to eq(1)
        expect(Job.last.resume.content).to be_present
        expect(Job.last.resume.content).to eq('This is the resume content from pdf file!')
      end
    end

    context 'when the form is invalid' do
      it 'renders errors inline' do
        visit new_job_path

        fill_in 'Job Title', with: invalid_attributes[:title]
        fill_in 'Company Name', with: invalid_attributes[:company]
        fill_in 'Location', with: invalid_attributes[:location]
        fill_in 'Job Description', with: invalid_attributes[:description]

        click_button 'Generate Cover Letter'

        expect(page).to have_content("Title can't be blank")
        expect(page).to have_content("Company can't be blank")
        expect(page).to have_content("Location can't be blank")
        expect(page).to have_content("Description can't be blank")
        expect(Job.count).to eq(0)
      end
    end
  end
end
