require 'rails_helper'

RSpec.describe 'Jobs management', type: :system, js: true do
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

  describe 'Job index' do
    it 'displays a list of jobs' do
      Job.create!(valid_attributes.merge(user: @user))

      visit jobs_path

      expect(page).to have_content(valid_attributes[:title])
      expect(page).to have_content(valid_attributes[:company])
    end

    it 'Updates \'Cover Letters Generated!\' count' do
      create(:cover_letter_count)
      visit new_job_path

      expect(page).to have_content(/0 Cover Letters Generated!/)

      create(:cover_letter)

      expect(page).to have_content(/1 Cover Letters Generated!/)
    end

    it 'allows to set applied' do
      job = Job.create!(valid_attributes.merge(user: @user))
      expect(job.applied).to eq(false)
      expect(page).to_not have_selector('.line-through')

      visit jobs_path
      check 'job_applied'
      expect(page).to have_checked_field('job_applied')
      job.reload

      expect(job.applied).to eq(true)
      expect(page).to have_selector('.line-through')
    end
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
