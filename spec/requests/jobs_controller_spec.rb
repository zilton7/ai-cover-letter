require 'rails_helper'

RSpec.describe 'JobsControllers', type: :request do
  let(:valid_attributes) do
    {
      title: 'MyJob',
      company: 'MyJobCompany',
      location: 'Remote',
      description: 'MyJobCompany',
      resume: 'MyJobCompany'
    }
  end

  let(:invalid_attributes) do
    {
      title: '',
      company: '',
      location: '',
      description: '',
      resume: ''
    }
  end

  describe 'GET #new' do
    it 'assigns a new job as @job' do
      get new_job_path

      expect(assigns(:job)).to be_a_new(Job)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Job' do
        expect do
          post(
            jobs_path,
            params: { job: valid_attributes }
          )
        end.to change(Job, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'doesn\'t create a new Job' do
        expect do
          post(
            jobs_path,
            params: { job: invalid_attributes }
          )
        end.to change(Job, :count).by(0)
      end
    end
  end

  describe 'GET /index' do
    let!(:job1) { create(:job) }

    it 'assigns @ params' do
      get jobs_path

      expect(assigns(:jobs).to_a).to be_a(Array)
      expect(assigns(:jobs)).to include(job1)
    end

    it 'loads all user\'s jobs' do
      get jobs_path

      expect(response.body).to include('MyJob')
    end
  end
end
