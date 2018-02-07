# frozen_string_literal: true

module SpecSupport
  module Controllers
    module StubCurrentConference
      def stub_current_conference
        current_conference { instance_double Conference, theme: 'it_tour' }
      end

      def current_conference(&block)
        let :current_conference, &block

        before do
          allow(controller).to receive(:current_conference).and_return current_conference
        end
      end
    end
  end
end
