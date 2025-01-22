require 'rails_helper'

RSpec.describe Resume, type: :model do
  let(:job) { create(:job) }

  describe 'associations' do
    it { is_expected.to belong_to(:job).optional }
    it { should have_one_attached(:file) }
  end

  describe 'validations' do
    it 'allows PDF files' do
      resume = Resume.new(job: job)
      file = fixture_file_upload('spec/fixtures/files/resume_for_test.pdf', 'application/pdf')
      resume.file.attach(file)

      expect(resume).to be_valid
    end

    it 'rejects non-PDF files' do
      resume = Resume.new(job: job)
      file = fixture_file_upload('spec/fixtures/files/image.png', 'image/png')
      resume.file.attach(file)

      expect(resume).not_to be_valid
      expect(resume.errors[:file]).to include('must be a PDF')
    end
  end

  describe '#extract_content' do
    let(:resume) { create(:resume, job: job) }

    context 'when file is attached' do
      before do
        pdf_content = StringIO.new('Sample PDF content')
        allow(PDF::Reader).to receive(:new).and_return(
          instance_double(PDF::Reader, pages: [
                            instance_double(PDF::Reader::Page, text: 'Page 1 content'),
                            instance_double(PDF::Reader::Page, text: 'Page 2 content')
                          ])
        )

        file = fixture_file_upload('spec/fixtures/files/resume_for_test.pdf', 'application/pdf')
        resume.file.attach(file)
      end

      it 'extracts and saves content from PDF' do
        resume.extract_content

        expect(resume.content).to include('Page 1 content', 'Page 2 content')
      end
    end

    context 'when file is not attached' do
      it 'returns nil without processing' do
        resume.file.attach(nil)

        expect(resume.extract_content).to be_nil
      end
    end

    context 'when PDF is malformed' do
      before do
        allow(PDF::Reader).to receive(:new)
          .and_raise(PDF::Reader::MalformedPDFError.new('Bad PDF'))

        file = fixture_file_upload('spec/fixtures/files/resume_for_test.pdf', 'application/pdf')
        resume.file.attach(file)
      end

      it 'adds error message' do
        resume.extract_content

        expect(resume.errors[:file]).to include('could not be processed: Bad PDF')
      end
    end

    context 'when unexpected error occurs' do
      before do
        allow(PDF::Reader).to receive(:new)
          .and_raise(StandardError.new('Unexpected error'))

        file = fixture_file_upload('spec/fixtures/files/resume_for_test.pdf', 'application/pdf')
        resume.file.attach(file)
      end

      it 'adds error message' do
        resume.extract_content

        expect(resume.errors[:file]).to include('unexpected error occurred: Unexpected error')
      end
    end
  end
end
