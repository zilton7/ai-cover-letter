module OmniauthMacros
  def mock_facebook_auth_hash
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(
      {
        provider: 'facebook',
        uid: '123456',
        info: {
          name: 'John Doe',
          email: 'johndoe@example.com',
          first_name: 'John',
          last_name: 'Doe'
        },
        credentials: {
          token: 'mock_token',
          expires_at: Time.now + 1.week
        }
      }
    )
  end

  def mock_facebook_invalid_auth_hash
    OmniAuth.config.mock_auth[:facebook] = :invalid_credentials
  end

  def mock_google_oauth2_auth_hash
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      {
        provider: 'google_oauth2',
        uid: '123456',
        info: {
          email: 'johndoe@example.com'
        },
        credentials: {
          token: 'mock_token',
          expires_at: Time.now + 1.week
        }
      }
    )
  end

  def mock_google_oauth2_invalid_auth_hash
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
  end
end
