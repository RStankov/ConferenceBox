# frozen_string_literal: true

require 'spec_helper'

describe EventDecorator do
  describe '#show_call_to_papers?' do
    def show_call_to_papers?(event)
      EventDecorator.new(event).show_call_to_papers?
    end

    it 'returns false if call to papers is nil' do
      event = Event.new(call_to_papers_url: nil)
      expect(show_call_to_papers?(event)).to eq false
    end

    it 'returns true if call to papers is set' do
      event = Event.new(call_to_papers_url: 'http://example.org')
      expect(show_call_to_papers?(event)).to eq true
    end

    it 'returns false if call to papers is set and sessions are announced' do
      event = Event.new(call_to_papers_url: 'http://example.org', sessions_announced: true)
      expect(show_call_to_papers?(event)).to eq false
    end
  end
end
