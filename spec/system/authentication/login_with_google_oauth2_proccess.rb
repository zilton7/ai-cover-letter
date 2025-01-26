# spec/features/user_sign_in_with_facebook_spec.rb
require 'rails_helper'
require 'sidekiq/testing'

RSpec.feature 'LoginWithGoogleOauth2Process', type: :system, js: true do
  scenario 'existing user signs in with google_oauth2' do
    create(:user, email: 'johndoe@example.com')
    mock_google_oauth2_auth_hash

    visit new_user_session_path
    find('#login_with_google_oauth2').click

    expect(page).to have_content('Successfully authenticated from Google account.')
    expect(page).to have_content('Account')
  end

  scenario 'user fails to sign in with google_oauth2' do
    mock_google_oauth2_invalid_auth_hash
    visit new_user_session_path
    find('#login_with_google_oauth2').click

    expect(page).to have_content(/Could not authenticate/)
    expect(current_path).to eq(new_user_session_path)
  end
end
