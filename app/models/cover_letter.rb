class CoverLetter < ApplicationRecord
  belongs_to :job

  def title_with_datetime
    "#{job.title} - #{created_at.strftime('%m/%d/%Y - %-I:%M %p')}"
  end
end
