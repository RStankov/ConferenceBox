# frozen_string_literal: true

module SpecSupport
  module Controllers
    module PermittedParams
      def permitted_params(params)
        ActionController::Parameters.new(params).permit!
      end
    end
  end
end
