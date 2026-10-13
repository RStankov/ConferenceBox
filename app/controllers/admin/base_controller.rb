# frozen_string_literal: true

class Admin::BaseController < ActionController::Base
  include SetupController
  include CurrentUserMethods
  include ActiveStorage::SetCurrent

  layout 'admin'
end
