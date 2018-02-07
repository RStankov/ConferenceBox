# frozen_string_literal: true

class BackdoorController < ActionController::Base
  before_action :restrict_access unless Rails.env.test?

  def login
    session[:user_id] = User.find_by_email!(params[:email]).id
    head :ok
  end

  def logout
    reset_session
    head :ok
  end

  private

  def prevent_from_execution_outside_test_environment
    raise 'How is this possible?!'
  end
end
