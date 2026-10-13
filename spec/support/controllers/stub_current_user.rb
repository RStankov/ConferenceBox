# frozen_string_literal: true

module SpecSupport
  module Controllers
    module StubCurrentUser
      def stub_current_user(role: :admin)
        attr_reader :current_user

        role_methods = {
          admin?: role == :admin,
          organizer?: role == :organizer,
          reviewer?: role == :reviewer,
          organizer_access?: %i(admin organizer).include?(role),
        }

        before do
          @current_user = block_given? ? yield : instance_double(User, role_methods)
          allow(controller).to receive(:current_user).and_return @current_user
        end
      end
    end
  end
end
