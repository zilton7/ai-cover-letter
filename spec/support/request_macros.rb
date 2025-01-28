module RequestMacros
  def login_user(user = nil)
    before(:each) do
      @user = user || create(:user)
      sign_in @user
    end
  end
end
