# frozen_string_literal: true

class Admin::BaseController < ActionController::Base
  include SetupController
  include CurrentUserMethods

  layout 'admin'
end
