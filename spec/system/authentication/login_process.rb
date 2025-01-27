require 'rails_helper'

RSpec.describe 'LoginProcess', type: :system, js: true do
  let(:password) { '123456789' }
  let(:user) do
    FactoryBot.create(:user, {
                        password:,
                        password_confirmation: password
                      })
  end

  it 'should require the user to log in and successfully logs in' do
    visit root_path

    within '#navbar' do
      click_on 'Login'
    end

    within '#new_user' do
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password
      click_on 'Login'
    end

    expect(page).to have_content('Subscription')
  end

  it 'should fail on an invalid user' do
    visit root_path

    within '#navbar' do
      click_on 'Login'
    end

    within '#new_user' do
      fill_in 'user_email', with: 'test'
      fill_in 'user_password', with: 'password'
      click_on 'Login'
    end

    expect(current_path).to eql(new_user_session_path)
  end
end
