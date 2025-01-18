class Resume < ApplicationRecord
  has_one_attached :file, dependent: :purge

  belongs_to :job

  validate :validate_file_type

  # Method to extract content from the PDF
  def extract_content
    return unless file.attached?

    content = ''
    reader = PDF::Reader.new(StringIO.new(file.download)) # Wrap content in StringIO
    reader.pages.each { |page| content += page.text }

    update(content:)
  rescue PDF::Reader::MalformedPDFError => e
    errors.add(:file, "could not be processed: #{e.message}")
  rescue StandardError => e
    errors.add(:file, "unexpected error occurred: #{e.message}")
  end

  private

  def validate_file_type
    return unless file.attached? && !file.content_type.in?(%w[application/pdf])

    errors.add(:file, 'must be a PDF')
  end
end
