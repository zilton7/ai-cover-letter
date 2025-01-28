class Subscription < ApplicationRecord
  belongs_to :user

  def plan_name
    plan.gsub('_', ' ').titleize
  end

  def status_name
    status.gsub('_', ' ')
  end
end
