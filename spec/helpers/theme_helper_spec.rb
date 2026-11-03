# frozen_string_literal: true

require 'spec_helper'

describe ThemeHelper do
  describe '#theme_root_attributes' do
    it 'passes the event color as the accent token' do
      attributes = helper.theme_root_attributes build(:event, color: '#ff0000')
      expect(attributes[:style]).to eq '--cb-accent: #ff0000;'
      expect(attributes['data-theme']).to eq 'auto'
    end

    it 'skips the style when there is no color' do
      expect(helper.theme_root_attributes(build(:event, color: nil))).not_to have_key :style
      expect(helper.theme_root_attributes(build(:conference))).not_to have_key :style
    end
  end

  describe '#social_icon_class' do
    it 'maps known networks to font awesome classes' do
      expect(helper.social_icon_class('twitter')).to eq 'fa fa-twitter'
      expect(helper.social_icon_class('linked-in')).to eq 'fa fa-linkedin'
    end

    it 'falls back to a generic link icon' do
      expect(helper.social_icon_class('mastodon')).to eq 'fa fa-link'
    end
  end

  describe '#section_heading' do
    it 'renders the label, title and subtitle' do
      html = helper.section_heading('Speakers', label: 'Who', subtitle: 'Listen')
      expect(html).to include '<span class="cb-section-label">Who</span>'
      expect(html).to include '<h2>Speakers</h2>'
      expect(html).to include '<p class="cb-section-subtitle">Listen</p>'
    end
  end

  describe '#conference_social_links' do
    it 'lists only the accounts that are set' do
      conference = build :conference, facebook_account: 'ittour', twitter_account: nil, youtube_account: 'ittourbg'
      expect(helper.conference_social_links(conference)).to eq [
        ['facebook', 'https://www.facebook.com/ittour'],
        ['youtube', 'https://youtube.com/ittourbg'],
      ]
    end
  end
end
