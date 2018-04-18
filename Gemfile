# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.3.1'

gem 'pg', '>= 0.18', '< 2.0'
gem 'rails', '~> 5.2.0.rc1'

gem 'aws-sdk-s3'
gem 'bcrypt', '~> 3.1.7'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap'
gem 'coffee-rails', '~> 4.2'
gem 'draper'
gem 'font-awesome-sass', '4.0.3.1'
gem 'jquery-rails'
gem 'kaminari'
gem 'loofah'
gem 'mini_magick'
gem 'puma', '~> 3.11'
gem 'redcarpet'
gem 'responders'
gem 'sass-rails', '~> 5.0'
gem 'simple_form'
gem 'slim'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  gem 'byebug', platforms: %i(mri mingw x64_mingw)
  gem 'pry'
end

group :development do
  gem 'annotate'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
end
