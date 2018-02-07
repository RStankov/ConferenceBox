# frozen_string_literal: true

module SetupController
  extend ActiveSupport::Concern

  included do
    protect_from_forgery with: :exception

    respond_to :html

    self.responder = ApplicationResponder
  end
end
