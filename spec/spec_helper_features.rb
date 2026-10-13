# frozen_string_literal: true

require 'spec_helper'

require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/session'

RSpec.configure do |config|
  config.include SpecSupport::Features::Authentication, type: :feature
  config.extend SpecSupport::Features::ConferenceEvent, type: :feature
end

Capybara.register_driver(:chrome) do |app|
  options = Selenium::WebDriver::Chrome::Options.new(args: %w(window-size=1024,768))
  options.add_argument('headless') unless ENV['TEST_DEBUG']

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.configure do |config|
  config.javascript_driver = :chrome
  config.default_max_wait_time = 5
end
