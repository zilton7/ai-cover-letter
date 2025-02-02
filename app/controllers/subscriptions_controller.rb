class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @title = 'Your Subscription'
  end
end
