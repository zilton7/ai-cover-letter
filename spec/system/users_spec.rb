require 'rails_helper'

RSpec.describe 'Users management', type: :system, js: true do
  login_user

  before do
    create(:job, user: @user)
  end

  describe 'Member user' do
    # it 'can login' do
    #   visit new_user_session_path
    #   fill_in 'user[email]', with: @user.email
    #   fill_in 'user[password]', with: @user.password
    #   click_button 'Log in'
    # end

    it 'can access it' do
      visit root_path

      expect(page).to have_content('Subscription')
    end

    it 'can access jobs index view' do
      visit root_path

      expect(page).to have_content('Your Jobs')
    end

    it 'can see only its jobs' do
      create(:job, title: 'My Job', user: @user)
      create(:job, title: 'Other User Job', user: create(:user))

      visit jobs_path

      within('turbo-frame#jobs') do
        expect(page).to have_content(/My Job/)
        expect(page).to_not have_content(/Other User Job/)
      end
    end
  end

  # it 'cant access jobs index view' do
  #   visit jobs_path

  #   expect(page).to have_content('Your Jobs')
  # end
end
