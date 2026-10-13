# frozen_string_literal: true

require 'spec_helper'

describe EventDecorator do
  describe '#show_call_to_papers?' do
    def show_call_to_papers?(event)
      EventDecorator.new(event).show_call_to_papers?
    end

    it 'returns false if call to papers is nil' do
      event = Event.new(call_to_papers_url: nil)
      expect(show_call_to_papers?(event)).to be false
    end

    it 'returns true if call to papers is set' do
      event = Event.new(call_to_papers_url: 'http://example.org')
      expect(show_call_to_papers?(event)).to be true
    end

    it 'returns false if call to papers is set and sessions are announced' do
      event = Event.new(call_to_papers_url: 'http://example.org', sessions_announced: true)
      expect(show_call_to_papers?(event)).to be false
    end

    it 'returns true if an in-app call for papers is open' do
      event = build :event, cfp_window: build(:cfp_window)
      expect(show_call_to_papers?(event)).to be true
    end

    it 'returns false if the in-app call for papers is closed and there is no url' do
      event = build :event, cfp_window: build(:closed_cfp_window)
      expect(show_call_to_papers?(event)).to be false
    end
  end

  describe '#call_to_papers_path' do
    it 'points to the in-app call for papers when it is open' do
      event = build :event, cfp_window: build(:cfp_window), call_to_papers_url: 'http://example.org'
      expect(described_class.new(event).call_to_papers_path).to eq '/cfp'
    end

    it 'falls back to the external url' do
      event = build :event, cfp_window: build(:closed_cfp_window), call_to_papers_url: 'http://example.org'
      expect(described_class.new(event).call_to_papers_path).to eq 'http://example.org'
    end
  end
end
