# frozen_string_literal: true

module SpecSupport
  module Controllers
    module RespondWith
      def self.included(base)
        base.before do
          allow(controller).to receive_messages(respond_with: nil, render: '')
        end
      end

      def respond_with(object, options = nil)
        if options
          have_received(:respond_with).with object, options
        else
          have_received(:respond_with).with object
        end
      end

      def render(*args)
        if args.any?
          have_received(:render).with(*args)
        else
          have_received(:render)
        end
      end
    end
  end
end
