class Job < ApplicationRecord
  has_many :cover_letters, dependent: :destroy

  validates_presence_of :title, :company, :location, :description, :resume
end
