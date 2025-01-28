require 'rails_helper'

RSpec.describe 'Jobs', type: :request do
  login_user

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        job: {
          title: 'Software Engineer',
          company: 'Tech Corp',
          location: 'New York, NY',
          description: 'Looking for a Software Engineer to join our team.',
          resume_attributes: {
            file: fixture_file_upload(Rails.root.join('spec/fixtures/files/resume_for_test.pdf'), 'application/pdf')
          }
        }
      }
    end

    let(:invalid_attributes) do
      {
        job: {
          title: '',
          company: '',
          location: '',
          description: ''
        }
      }
    end

    let(:invalid_resume_attributes) do
      file = fixture_file_upload(Rails.root.join('spec/fixtures/files/image.png'), 'image/png')
      valid_attributes[:job][:resume_attributes][:file] = file
      valid_attributes
    end

    before do
      allow(GenerateCoverLetterGroqAiJob).to receive(:perform_async)
    end

    context 'with valid parameters' do
      it 'creates a new job' do
        expect do
          post jobs_path, params: valid_attributes, as: :turbo_stream
        end.to change(Job, :count).by(1)
      end

      it 'triggers the background job' do
        post jobs_path, params: valid_attributes, as: :turbo_stream
        job = Job.last
        replacements = {
          job_title: job.title,
          resume: job.resume.content,
          job_description: job.description,
          company: job.company
        }.to_json

        expect(GenerateCoverLetterGroqAiJob).to have_received(:perform_async).with(job.id, replacements)
      end

      it 'renders the Turbo Stream response' do
        post jobs_path, params: valid_attributes, as: :turbo_stream

        expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
        expect(response.body).to include('turbo-modal')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new job' do
        expect do
          post jobs_path, params: invalid_attributes, as: :turbo_stream
        end.not_to change(Job, :count)
      end
    end

    context 'with invalid resume format' do
      it 'does not create a new job' do
        expect do
          post jobs_path, params: invalid_resume_attributes, as: :turbo_stream
        end.not_to change(Job, :count)
      end

      it 'renders the new template with errors' do
        post jobs_path, params: invalid_resume_attributes, as: :turbo_stream

        expect(assigns(:job).errors['resume.file']).to include('must be a PDF')
      end
    end
  end

  describe 'PATCH #update' do
    let!(:job) { create(:job, user: @user) }

    let(:valid_attributes) do
      {
        description: 'Updated description.',
        resume_attributes: {
          file: fixture_file_upload(Rails.root.join('spec/fixtures/files/resume_for_test.pdf'), 'application/pdf')
        }

      }
    end

    let(:invalid_attributes) do
      {
        description: ''
      }
    end

    before do
      allow(GenerateCoverLetterGroqAiJob).to receive(:perform_async)
    end

    context 'with valid parameters' do
      it 'updates the job and redirects' do
        patch job_path(job), params: { id: job.id, job: valid_attributes }, as: :turbo_stream

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
        expect(response.body).to include('turbo-modal')
        expect(job.reload.description).to eq('Updated description.')
      end

      it 'triggers the AI job processing' do
        expect(GenerateCoverLetterGroqAiJob).to receive(:perform_async).with(
          job.id, { job_title: 'MyJob', resume: 'This is the resume content from pdf file!',
                    job_description: 'Updated description.', company: 'MyJobCompany' }.to_json
        )

        patch job_path(job), params: { id: job.id, job: valid_attributes }, as: :turbo_stream
      end
    end

    context 'with invalid attributes' do
      before do
        patch job_path(job), params: { id: job.id, job: invalid_attributes }, as: :turbo_stream
      end

      it 'does not update the job and renders the edit form' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template('jobs/_form')
        expect(job.reload.title).not_to eq('')
      end

      it 'returns error for invalid input' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(assigns(:job).errors['description']).to include('can\'t be blank')
      end
    end
  end
end
