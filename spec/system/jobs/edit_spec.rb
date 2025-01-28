require 'rails_helper'

RSpec.describe 'Jobs edit', type: :system, js: true do
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

  def go_to_job_details(job)
    visit jobs_path
    click_on job.full_title

    click_on 'Create Additional Cover Letter'
  end

  describe 'Job edit' do
    let!(:job) { create(:job, :with_cover_letter, user: @user) }

    it 'displays job details' do
      go_to_job_details(job)

      within('turbo-frame#jobs-form') do
        expect(page).to have_field('Job Title', with: 'MyJob', readonly: true)
        expect(page).to have_field('Company Name', with: 'MyJobCompany', readonly: true)
        expect(page).to have_field('Location', with: 'Remote', readonly: true)
        expect(page).to have_field('Job Description', with: 'MyJobDescription', readonly: false)
      end
    end

    it 'allows editing description only' do
      go_to_job_details(job)

      fill_in 'Company Name', with: 'This is my new MyJobCompany'
      fill_in 'Job Description', with: 'This is my new job description'

      expect(page).to_not have_field('Company Name', with: 'This is my new MyJobCompany')
      expect(page).to have_field('Job Description', with: 'This is my new job description')
    end

    let(:replacements) do
      {
        job_title: job.title,
        resume: 'This is the resume content from pdf file!',
        job_description: job.description,
        company: job.company
      }.to_json
    end

    let(:mocked_prompt) do
      "Dear Hiring Manager,\n\nI am excited to apply for the Software Engineer position at Tech Corp. \
        With experience in Ruby on Rails, React, and Postgres, I am confident in my ability to contribute \
        to your team's success.\n\nSincerely,\nCandidate Name"
    end

    let(:mocked_groq_ai_api_response) do
      { 'choices': [{ 'message': { 'content': 'This is the additinally created content' } }] }.with_indifferent_access
    end

    it 'allows to update job' do
      allow(PromptGenerator).to receive(:generate)
        .with(replacements)
        .and_return(mocked_prompt)

      # Mock the service
      service = instance_double(GroqAiApiService, call: mocked_groq_ai_api_response)
      allow(GroqAiApiService).to receive(:new).with(mocked_prompt).and_return(service)

      go_to_job_details(job)

      within('turbo-frame#jobs-form') do
        # Attach the file to the hidden file input and trigger the change event
        file_path = valid_attributes[:resume_attributes][:file].path
        attach_file('resume-file-upload', file_path, visible: false)
        page.execute_script("document.getElementById('resume-file-upload').dispatchEvent(new Event('change'));")

        click_on 'Create New Cover Letter'
      end

      expect(page).to have_selector('#turbo-modal')
      expect(CoverLetter.count).to eq(2)
    end

    it 'throws error when no resume file provided' do
      go_to_job_details(job)

      click_on 'Create New Cover Letter'

      expect(page).to have_content('Resume can\'t be blank')
    end

    it 'displays existing cover letters' do
      visit jobs_path
      click_on job.full_title

      click_on 'Display Cover Letters'
      cover_letter_title = job.cover_letters.first.title_with_datetime

      expect(page).to have_content(cover_letter_title)
      expect(page).to have_content('This is the content created by FactoryBot')
    end
  end
end
