# frozen_string_literal: true

module CurrentUserMethods
  extend ActiveSupport::Concern

  included do
    helper_method :current_user

    before_action :require_user
  end

  private

  def require_user
    return unless current_user.blank?

    redirect_to sign_in_path
  end

  def current_user
    if defined? @current_user
      @current_user
    else
      @current_user = session[:user_id] && User.find(session[:user_id])
    end
  end
end
