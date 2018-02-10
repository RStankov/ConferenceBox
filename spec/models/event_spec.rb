# frozen_string_literal: true

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
