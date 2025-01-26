require 'rails_helper'

RSpec.describe 'RegistrationProcess', type: :system, js: true do
  # close flash message if existing
  # before do
  #   page.click_link('close-flash-notification') if page.has_link?('close-flash-notification')
  # end

  it 'should require the user to sign up and successfully sign up' do
    visit root_path

    within '#navbar' do
      click_on 'Register'
    end

    within '#new_user' do
      fill_in 'user_email', with: 'test@test.com'
      fill_in 'user_password', with: 'password123'
      fill_in 'user_password_confirmation', with: 'password123'
      click_on 'Register'
    end

    expect(page).to have_content('Cover Letters Generated!')
  end

  it 'should fail on invalid user information' do
    visit root_path

    find('.navbar-toggler').click if has_css?('.navbar-toggler', visible: true)

    within '#navbar' do
      click_on 'Register'
    end

    within '#new_user' do
      fill_in 'user_email', with: 'test'
      fill_in 'user_password', with: 'p'
    end

    click_button 'Register'

    expect(current_path).to eql(new_user_registration_path)
    expect(page).to have_content(/Email is Invalid/i)
    expect(page).to have_content(/minimum is 6 characters/i)
    expect(page).to have_content(/Password confirmation doesn't match Password/i)
  end
end
