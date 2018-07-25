# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SetupController
  include CurrentConferenceMethods

  before_action do
    ActiveStorage::Current.host = request.base_url
  end
end
