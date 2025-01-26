class CoverLetterCount < ApplicationRecord
  def self.count
    CoverLetterCount.first&.count&.positive? ? CoverLetterCount.first.count : 0
  end

  def self.increment
    CoverLetterCount.first&.increment!(:count)
  end

  def self.decrement
    CoverLetterCount.first&.decrement!(:count)
  end
end
