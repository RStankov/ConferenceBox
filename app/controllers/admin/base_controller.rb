# frozen_string_literal: true

class Admin::BaseController < ActionController::Base
  include CurrentUserMethods

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout 'admin'

  respond_to :html

  self.responder = ApplicationResponder
end
