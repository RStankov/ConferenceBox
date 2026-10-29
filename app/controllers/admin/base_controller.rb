# frozen_string_literal: true

class Admin::BaseController < ActionController::Base
  include SetupController
  include CurrentUserMethods
  include ActiveStorage::SetCurrent

  layout 'admin'

  before_action :require_organizer_access

  private

  def require_organizer_access
    forbidden unless current_user.organizer_access?
  end

  def require_admin_access
    forbidden unless current_user.admin?
  end

  def forbidden
    render 'admin/shared/forbidden', status: :forbidden
  end
end
