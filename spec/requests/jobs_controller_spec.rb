require 'rails_helper'

RSpec.describe JobsController, type: :controller do
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

    before do
      allow(GenerateCoverLetterGroqAiJob).to receive(:perform_async)
    end

    context 'with valid parameters' do
      it 'creates a new job' do
        expect do
          post :create, params: valid_attributes, format: :turbo_stream
        end.to change(Job, :count).by(1)
      end

      it 'triggers the background job' do
        post :create, params: valid_attributes, format: :turbo_stream
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
        post :create, params: valid_attributes, format: :turbo_stream

        expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
        expect(response.body).to include('turbo-modal')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new job' do
        expect do
          post :create, params: invalid_attributes, format: :turbo_stream
        end.not_to change(Job, :count)
      end

      it 'renders the new template with errors' do
        post :create, params: invalid_attributes, format: :html

        expect(response).to render_template(:new)
        expect(assigns(:job).errors).not_to be_empty
      end
    end
  end
end
