class CoverLetter < ApplicationRecord
  belongs_to :job

  after_create :increment_cover_letter_count
  after_destroy :decrement_cover_letter_count
  after_create_commit :display_cover_letters_count

  def title_with_datetime
    "#{job.title} - #{created_at.strftime('%m/%d/%Y - %-I:%M %p')}"
  end

  private

  def increment_cover_letter_count
    CoverLetterCount.first&.increment!(:count)
  end

  def decrement_cover_letter_count
    CoverLetterCount.first&.decrement!(:count)
  end

  def display_cover_letters_count
    broadcast_update_to 'cover-letters-count', target: 'cover-letters-count',
                                               html: CoverLetterCount.first&.count.to_s || 0
  end
end
