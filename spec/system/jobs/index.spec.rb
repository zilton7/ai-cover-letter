require 'rails_helper'

RSpec.describe 'Jobs index', type: :system, js: true do
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

    it 'displays pagination' do
      10.times do
        Job.create!(valid_attributes.merge(user: @user))
      end
      visit jobs_path

      expect(page).to have_css "a[href='/jobs?page=2']", text: 'Load More'
      click_on 'Load More'
      expect(page).to_not have_css 'a', text: 'Load More'
    end
  end
end
