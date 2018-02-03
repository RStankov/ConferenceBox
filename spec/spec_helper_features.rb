require 'spec_helper'

require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/session'

ConferenceBox::Application.config.cache_classes = true

RSpec.configure do |config|
  config.include SpecSupport::Features::Authentication, type: :feature
  config.extend SpecSupport::Features::ConferenceEvent, type: :feature

  config.use_transactional_fixtures = false

  config.before :each do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end


Capybara.register_driver(:chrome) do |app|
  chrome_args = %w[window-size=1024,768]
  chrome_args += %w[headless disable-gpu] unless ENV['TEST_DEBUG']

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(chromeOptions: { args: chrome_args })
  )
end

Capybara.configure do |config|
  config.javascript_driver = :chrome
  config.default_max_wait_time = 5
end
