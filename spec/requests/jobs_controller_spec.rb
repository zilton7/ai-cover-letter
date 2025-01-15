require 'rails_helper'

RSpec.describe "JobsControllers", type: :request do
  describe "GET /index" do
    it 'loads today\'s all jobs' do
      get jobs_path()

      expect(response.body).to include('products launching Today')
    end
  end
end
