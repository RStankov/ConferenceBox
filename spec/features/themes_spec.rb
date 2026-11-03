# frozen_string_literal: true

require 'spec_helper_features'

feature 'Public themes' do
  let(:conference) { create :conference, domain: 'example.com', theme: theme, facebook_account: 'conf' }
  let!(:event) do
    create :current_event,
           conference: conference,
           color: '#123456',
           dates_announced: true,
           venue_announced: true,
           venue_name: 'Big Hall',
           sessions_announced: true,
           speakers_announced: true,
           sponsors_announced: true
  end
  let(:speaker) { create :speaker, name: 'Ada Lovelace', company: 'Analytical Engines', twitter_account: 'https://twitter.com/ada' }

  before do
    create :session, event: event, title: 'Opening keynote', start_at: '09:00', speakers: [speaker]
    create :session, event: event, title: 'Closing notes', start_at: '17:00', track: 2
    event.sponsors << create(:sponsor, name: 'Test Inc')
  end

  context 'with the plain theme' do
    let(:theme) { 'plain' }

    it 'renders the event sections with the accent color' do
      visit root_path

      expect(page).to have_css 'html[style*="--cb-accent: #123456"]'
      expect(page).to have_css '.hero h1', text: 'Conference name year name'
      expect(page).to have_css '.site-nav a', text: 'Schedule'
      expect(page).to have_css '#schedule .schedule li', count: 2
      expect(page).to have_css '#schedule .cb-badge', text: 'Track 2'
      expect(page).to have_text 'Ada Lovelace'
      expect(page).to have_css '#speakers .cb-badge', text: 'Analytical Engines'
      expect(page).to have_css 'footer .cb-social a[href="https://www.facebook.com/conf"]'
    end
  end

  context 'with the not_a_conf theme' do
    let(:theme) { 'not_a_conf' }

    it 'renders the schedule, speakers and venue' do
      event.update! venue_site_url: 'http://hall.example.org', venue_map_embedded_url: 'http://maps.example.org/embed'

      visit root_path

      expect(page).to have_css 'html[style*="--cb-accent: #123456"]'
      expect(page).to have_css '.schedule-track-label', text: 'Track 2'
      expect(page).to have_css '.schedule-slot-speaker-name', text: 'Ada Lovelace'
      expect(page).to have_css '.ts-speaker .cb-social a[href="https://twitter.com/ada"]'
      expect(page).to have_css '#ts-venue .venue-card a', text: 'Big Hall'
      expect(page).to have_css '#ts-venue iframe.map'
      expect(page).to have_css '.banner-meta span', text: 'Big Hall'
    end
  end

  context 'with the it_tour theme' do
    let(:theme) { 'it_tour' }

    it 'renders the hero, sticky nav and schedule cards' do
      visit root_path

      expect(page).to have_css 'header .hero h1', text: 'Conference name'
      expect(page).to have_css 'nav a', text: 'Програма'
      expect(page).to have_css '#schedule .schedule-card', count: 2
      expect(page).to have_css '#schedule .schedule-card time', text: '09:00'
      expect(page).to have_css '#speakers .speaker-card h3', text: 'Ada Lovelace'
      expect(page).to have_css 'footer .cb-social a[href="https://www.facebook.com/conf"]'
    end
  end
end
