require 'rails_helper'

RSpec.describe PromptGenerator do
  describe '.generate' do
    let(:replacements) do
      {
        job_title: 'Software Engineer',
        resume: 'John Doe, experienced developer with expertise in Ruby on Rails, JavaScript, and PostgreSQL.',
        job_description: 'We are looking for a skilled software engineer to join our dynamic team and work on scalable web applications.',
        company: 'Tech Innovators Inc.'
      }
    end

    it 'generates a cover letter with the provided replacements' do
      result = described_class.generate(replacements)

      expect(result).to include('Your task is to create professional and concise cover letters.')
      expect(result).to include('suitable for a Software Engineer.')
      expect(result).to include('This is my current resume. <Start of resume> John Doe, experienced developer with expertise in Ruby on Rails, JavaScript, and PostgreSQL. </end of resume>')
      expect(result).to include("Here is the job description for the job I'm applying for:<job description> We are looking for a skilled software engineer to join our dynamic team and work on scalable web applications.</job description>")
      expect(result).to include('and here is the name of the company: <company>Tech Innovators Inc.</company>')
    end

    it 'strips leading and trailing whitespace from the generated result' do
      result = described_class.generate(replacements)
      expect(result).not_to start_with("\n")
      expect(result).not_to end_with("\n")
    end

    it 'raises a KeyError if a required replacement is missing' do
      invalid_replacements = { job_title: 'Software Engineer' }
      expect { described_class.generate(invalid_replacements) }.to raise_error(KeyError)
    end
  end
end
