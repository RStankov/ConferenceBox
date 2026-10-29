# frozen_string_literal: true

require 'spec_helper_features'

feature 'Event page - call for papers section' do
  let(:conference) { create :conference, domain: 'example.com', theme: 'plain' }
  let(:event) { create :current_event, conference: conference, dates_announced: true }

  it 'links to the in-app call for papers while it is open' do
    create :cfp_window, event: event, closes_at: Time.zone.local(2030, 3, 1, 18)

    visit root_path

    expect(page).to have_text 'looking for speakers until March 01, 2030'
    expect(page).to have_link 'Submit a proposal', href: cfp_path
  end

  it 'falls back to the external link' do
    event.update! call_to_papers_url: 'http://forms.example.org/cfp'

    visit root_path

    expect(page).to have_link 'Submit a proposal', href: 'http://forms.example.org/cfp'
  end

  it 'is hidden once the sessions are announced' do
    event.update! call_to_papers_url: 'http://forms.example.org/cfp', sessions_announced: true

    visit root_path

    expect(page).to have_no_text 'Call for papers'
  end
end
