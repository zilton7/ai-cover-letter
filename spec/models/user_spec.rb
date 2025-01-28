require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) do
    create(:user)
  end

  context 'valid Factory' do
    it 'has a valid factory' do
      expect(user).to be_valid
    end
  end

  describe 'associations' do
    it { should have_many(:subscriptions) }
    it { should have_many(:jobs) }
  end
end
