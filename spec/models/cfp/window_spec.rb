# frozen_string_literal: true

require 'spec_helper'

describe Cfp::Window do
  describe 'validations' do
    it 'requires closes_at to be after opens_at' do
      window = build :cfp_window, opens_at: Time.current, closes_at: 1.day.ago
      expect(window).to have_error_on :closes_at
    end

    it 'requires a positive submissions limit' do
      window = build :cfp_window, max_submissions_per_speaker: 0
      expect(window).to have_error_on :max_submissions_per_speaker
    end

    it 'allows one window per event' do
      window = create :cfp_window
      expect { create :cfp_window, event: window.event }.to raise_error ActiveRecord::RecordNotUnique
    end
  end

  describe '#status' do
    let(:window) { build :cfp_window, opens_at: Time.zone.local(2026, 1, 1), closes_at: Time.zone.local(2026, 2, 1) }

    it 'is upcoming before opens_at' do
      expect(window.status(Time.zone.local(2025, 12, 31))).to eq :upcoming
      expect(window.upcoming?(Time.zone.local(2025, 12, 31))).to be true
    end

    it 'is open between opens_at and closes_at' do
      expect(window.status(Time.zone.local(2026, 1, 15))).to eq :open
      expect(window.open?(Time.zone.local(2026, 1, 15))).to be true
    end

    it 'is closed after closes_at' do
      expect(window.status(Time.zone.local(2026, 2, 2))).to eq :closed
      expect(window.closed?(Time.zone.local(2026, 2, 2))).to be true
    end
  end

  describe '.open_at' do
    it 'returns windows that are open at the given time' do
      open_window = create :cfp_window
      _closed_window = create :closed_cfp_window
      _upcoming_window = create :upcoming_cfp_window

      expect(described_class.open_at(Time.current)).to eq [open_window]
    end
  end

  describe '#track_list' do
    it 'splits tracks by line and ignores blanks' do
      window = build :cfp_window, tracks: " Backend \n\nFrontend\n"
      expect(window.track_list).to eq %w(Backend Frontend)
    end

    it 'is empty when there are no tracks' do
      expect(build(:cfp_window, tracks: nil).track_list).to eq []
    end
  end
end
