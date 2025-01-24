module SystemMacros
  def login_user
    before(:each) do
      @user = create(:user)
      login_as(@user, scope: :user)
    end
  end
end
