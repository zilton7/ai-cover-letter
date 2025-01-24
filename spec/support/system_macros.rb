module SystemMacros
  def login_user(user = nil)
    before(:each) do
      @user = user || create(:user)
      login_as(@user)
    end
  end
end
