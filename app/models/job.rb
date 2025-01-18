class Job < ApplicationRecord
  has_many :cover_letters, dependent: :destroy
  has_one :resume

  accepts_nested_attributes_for :resume

  validates_presence_of :title, :company, :location, :description
end
