# frozen_string_literal: true

require 'spec_helper'

describe Cfp::WindowDecorator do
  def decorate(window)
    described_class.decorate window
  end

  describe '#deadline_sentence' do
    it 'describes when an upcoming window opens' do
      window = build :upcoming_cfp_window, opens_at: Time.zone.local(2030, 3, 1, 9)
      expect(decorate(window).deadline_sentence).to start_with 'Opens March 01, 2030'
    end

    it 'describes when an open window closes' do
      window = build :cfp_window, closes_at: 2.weeks.from_now
      expect(decorate(window).deadline_sentence).to include 'Closes'
      expect(decorate(window).deadline_sentence).to include '14 days from now'
    end

    it 'describes when a closed window closed' do
      window = build :closed_cfp_window, closes_at: Time.zone.local(2020, 3, 1, 9)
      expect(decorate(window).deadline_sentence).to start_with 'Closed March 01, 2020'
    end
  end

  describe '#status_badge_type' do
    it 'maps status to a badge type' do
      expect(decorate(build(:cfp_window)).status_badge_type).to eq :success
      expect(decorate(build(:closed_cfp_window)).status_badge_type).to eq :danger
      expect(decorate(build(:upcoming_cfp_window)).status_badge_type).to eq :secondary
    end
  end
end
