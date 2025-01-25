require 'rails_helper'

RSpec.describe GenerateCoverLetterGroqAiJob, type: :job do
  describe '#perform' do
    let(:job_id) { create(:job).id }
    let(:replacements) { { company: 'Regional co-manager', role: 'Dunder Mifflin inc.' }.with_indifferent_access }
    let(:generated_prompt) { 'Generated prompt text' }
    let(:api_response) do
      {
        'choices' => [
          {
            'message' => {
              'content' => 'Generated cover letter content'
            }
          }
        ]
      }
    end

    before do
      # Mock PromptGenerator
      allow(PromptGenerator).to receive(:generate)
        .with(replacements)
        .and_return(generated_prompt)

      # Mock GroqAiApiService
      service = instance_double(GroqAiApiService, call: api_response)
      allow(GroqAiApiService).to receive(:new)
        .with(generated_prompt)
        .and_return(service)

      # Mock Turbo broadcast
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
    end

    it 'creates a cover letter and broadcasts the result' do
      require 'sidekiq/testing'
      Sidekiq::Testing.inline! # Makes Sidekiq run jobs immediately

      expect do
        described_class.new.perform(job_id, replacements)
      end.to change(CoverLetter, :count).by(1)

      cover_letter = CoverLetter.last
      expect(cover_letter.body).to eq('Generated cover letter content')
      expect(cover_letter.job_id).to eq(job_id)

      expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
        'ai_response',
        target: "ai_response_for_user_#{cover_letter.job.user.id}",
        partial: 'cover_letters/cover_letter',
        locals: { cover_letter: 'Generated cover letter content', user: cover_letter.job.user }
      )
    end

    context 'when API returns an error' do
      let(:api_response) do
        {
          'error' => 'API Error occurred'
        }
      end

      it 'handles the error appropriately' do
        expect do
          described_class.new.perform(job_id, replacements)
        end.to change(CoverLetter, :count).by(1)
        cover_letter = CoverLetter.last
        expect(cover_letter.body).to eq('Error: API Error occurred')

        expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
          'ai_response',
          target: "ai_response_for_user_#{cover_letter.job.user.id}",
          partial: 'cover_letters/cover_letter',
          locals: { cover_letter: 'Error: API Error occurred', user: cover_letter.job.user }
        )
      end
    end

    context 'when cover letter fails to save' do
      before do
        allow_any_instance_of(CoverLetter).to receive(:save).and_return(false)
      end

      let(:current_user) { User.last }

      it 'broadcasts an error message' do
        described_class.new.perform(job_id, replacements)

        expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
          'ai_response',
          target: "ai_response_for_user_#{current_user.id}",
          partial: 'cover_letters/cover_letter',
          locals: { cover_letter: 'Error Occured', user: current_user }
        )
      end
    end
  end
end
