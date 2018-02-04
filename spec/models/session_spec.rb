# frozen_string_literal: true

# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  start_at   :string(255)      not null
#  title      :string(255)      not null
#  slides_url :string(255)
#  video_url  :string(255)
#  created_at :datetime
#  updated_at :datetime
#  track      :integer          default(1), not null
#

require 'spec_helper'

describe Session do
  describe '(default scope)' do
    it 'orders session by start at' do
      at1230 = create :session, start_at: '12:30'
      at1510 = create :session, start_at: '15:10'
      at1420 = create :session, start_at: '14:20'

      expect(described_class.all).to eq [at1230, at1420, at1510]
    end
  end

  describe '.announced' do
    it 'includes only announced sessions' do
      _unannounced = create :session, event: create(:event, sessions_announced: false)
      announced = create :session, event: create(:event, sessions_announced: true)

      expect(described_class.announced).to eq [announced]
    end
  end

  describe '.by_track' do
    it 'groups by track number' do
      track1 = create :session, track: 1
      track2 = create :session, track: 2

      expect(described_class.by_track).to eq 1 => [track1], 2 => [track2]
    end
  end
end
