class GameClientController < ApplicationController
  before_action :login_user

  private

  def login_user
    prior_value = cookies.signed[:user_uuid]
    if prior_value.blank? || !User.has_uuid?(prior_value)
      cookies.signed[:user_uuid] = User.new.uuid
    end
  end
end
