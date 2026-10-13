# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ConferenceBox
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w(tasks))
    config.filter_parameters += %i(password password_confirmation)
    config.i18n.enforce_available_locales = true
    config.generators.system_tests = nil
    config.active_storage.variant_processor = :mini_magick
  end
end
