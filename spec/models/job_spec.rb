require 'rails_helper'

RSpec.describe Job, type: :model do
  let(:job) do
    create(:job,
           description: '   this has to have no leading or ending spaces   ')
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user).optional }
    it { should have_many(:cover_letters) }
    it { should have_one(:resume) }
  end

  it 'strips leading and ending spaces from description' do
    expect(job.description).to eq('this has to have no leading or ending spaces')
    expect(job.description).to_not eq('   this has to have no leading or ending spaces   ')
  end
end
