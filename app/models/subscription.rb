class Subscription < ApplicationRecord
  belongs_to :user

  def plan_name
    plan.gsub('_', ' ').titleize
  end

  def status_name
    status.gsub('_', ' ')
  end

  def active?
    status == 'active'
  end
end
