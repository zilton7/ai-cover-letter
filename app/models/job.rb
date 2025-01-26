class Job < ApplicationRecord
  has_many :cover_letters, dependent: :destroy
  has_one :resume

  belongs_to :user, optional: true

  before_create { description.strip! }

  accepts_nested_attributes_for :resume
  validates_presence_of :resume
  validates_associated :resume

  validates_presence_of :title, :company, :location, :description

  def full_title
    "#{title} @ #{company}"
  end

  def cover_letters_for_dropdown
    cover_letters.order(created_at: :desc).map { |cover_letter| [cover_letter.title_with_datetime, cover_letter.id] }
  end
end
