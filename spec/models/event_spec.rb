# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                                 :integer          not null, primary key
#  conference_id                      :integer
#  name                               :string(255)      not null
#  date                               :date             not null
#  publicly_announced                 :boolean          default(FALSE), not null
#  event_url                          :string(255)
#  venue_name                         :string(255)
#  venue_site_url                     :string(255)
#  venue_address                      :string(255)
#  venue_map_url                      :string(255)
#  venue_notes                        :text
#  created_at                         :datetime
#  updated_at                         :datetime
#  after_party_venue_name             :string(255)
#  after_party_venue_site_url         :string(255)
#  after_party_venue_address          :string(255)
#  after_party_venue_notes            :string(255)
#  after_party_venue_map_url          :text
#  town                               :string(255)
#  notes                              :text
#  dates_announced                    :boolean          default(FALSE)
#  venue_announced                    :boolean          default(FALSE)
#  after_party_announced              :boolean          default(FALSE)
#  sessions_announced                 :boolean          default(FALSE)
#  speakers_announced                 :boolean          default(FALSE)
#  logo                               :string(255)
#  coverart                           :string(255)
#  current                            :boolean          default(FALSE), not null
#  show_feedback_form                 :boolean          default(FALSE), not null
#  show_photo_gallery                 :boolean          default(FALSE), not null
#  streaming_code                     :text
#  show_streaming                     :boolean          default(FALSE), not null
#  show_coverart                      :boolean          default(FALSE), not null
#  color                              :string(255)
#  call_to_papers_url                 :string(255)
#  venue_map_embedded_url             :text
#  after_party_venue_map_embedded_url :text
#

require 'spec_helper'

describe Event do
  it 'has full name' do
    event = described_class.new name: '2013', conference: Conference.new(name: 'VarnaConf')
    expect(event.full_name).to eq 'VarnaConf 2013'
  end

  describe '#current' do
    it 'requires event to be publicly announced' do
      event = build :event, publicly_announced: false, current: true
      expect(event).not_to be_valid
    end

    it 'is only one per conference' do
      conference = create :conference

      event1 = create :current_event, conference: conference
      event2 = create :current_event, conference: conference

      expect(event1.reload).not_to be_current
      expect(event2.reload).to be_current
    end

    it 'doesnt care about current events in other conferences' do
      event1 = create :current_event
      event2 = create :current_event

      expect(event1.reload).to be_current
      expect(event2.reload).to be_current
    end
  end
end
