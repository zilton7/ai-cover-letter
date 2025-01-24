module RequestMacros
  def login_user
    before do
      @user ||= create(:user) # Use the existing factory to create a user if none is provided
      sign_in @user
    end
  end
end
