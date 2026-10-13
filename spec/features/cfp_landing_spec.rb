# frozen_string_literal: true

require 'spec_helper_features'

feature 'Call for papers landing page' do
  let(:conference) { create :conference, domain: 'example.com', theme: 'plain' }
  let(:event) { create :current_event, conference: conference }

  it 'explains that proposals are not accepted without a window' do
    event

    visit cfp_path

    expect(page).to have_text 'not accepting proposals'
  end

  it 'shows guidelines and tracks when the call is open' do
    create :cfp_window, event: event, guidelines: 'Talks should be **short**', tracks: "Backend\nFrontend"

    visit cfp_path

    expect(page).to have_text 'Open'
    expect(page).to have_text 'Closes'
    expect(page).to have_text 'Backend'
    expect(page).to have_css 'strong', text: 'short'
    expect(page).to have_text 'up to 3 proposals'
  end

  it 'shows closing information when the call is closed' do
    create :closed_cfp_window, event: event

    visit cfp_path

    expect(page).to have_text 'Closed'
    expect(page).to have_no_text 'up to 3 proposals'
  end
end
