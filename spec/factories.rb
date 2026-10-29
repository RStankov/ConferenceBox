# frozen_string_literal: true

FactoryBot.define do
  sequence(:session_start_at) { |n| "#{format('%02d', (23 - n / 60).abs)}:#{format('%02d', n % 60)}" }
  sequence(:email) { |n| "user-#{n}@example.org" }
  sequence(:domain) { |n| "example-#{n}.org" }

  factory :conference do
    name { 'Conference name' }
    contact_name { 'Contact person' }
    contact_email { 'contact@example.org' }
    domain { generate :domain }
    theme { 'it_tour' }
  end

  factory :event do
    conference
    name { 'year name' }
    date { Date.new(2013, 6, 20) }
    publicly_announced { true }
    current { false }

    factory :future_event do
      publicly_announced { false }
    end

    factory :current_event do
      current { true }
    end

    factory :finished_event do
      date { 1.year.ago }
    end
  end

  factory :session do
    event
    title { 'Session name' }
    start_at { generate :session_start_at }
  end

  factory :user do
    first_name             { 'Joe' }
    last_name              { 'Doe' }
    email                  { generate :email }
    password               { '123456' }
    password_confirmation  { '123456' }
    role                   { 'admin' }

    factory :organizer do
      role { 'organizer' }
    end

    factory :reviewer do
      role { 'reviewer' }
    end
  end

  factory :speaker do
    name { 'John Doe' }
  end

  factory :sponsor do
    name { 'Test Inc' }
    website_url { 'http://example.com' }
  end

  factory :subscriber do
    conference
    email { generate :email }
  end

  factory :cfp_window, class: 'Cfp::Window' do
    event
    opens_at { 1.day.ago }
    closes_at { 1.month.from_now }
    max_submissions_per_speaker { 3 }
    tracks { "Backend\nFrontend" }

    factory :closed_cfp_window do
      opens_at { 2.months.ago }
      closes_at { 1.month.ago }
    end

    factory :upcoming_cfp_window do
      opens_at { 1.month.from_now }
      closes_at { 2.months.from_now }
    end
  end

  factory :feedback do
    event
    comment { 'I liked the event' }
  end

  factory :photo do
    event
    asset { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/photo_asset.jpg').to_s) }
  end

  factory :session_speaker do
    session { build :session }
    speaker { build :speaker }
  end
end
