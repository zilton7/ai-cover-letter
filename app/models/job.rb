class Job < ApplicationRecord
  has_many :cover_letters

  validates_presence_of :title, :company, :location, :description, :cv
end
