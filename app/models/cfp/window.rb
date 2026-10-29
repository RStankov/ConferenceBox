# frozen_string_literal: true

# == Schema Information
#
# Table name: cfp_windows
#
#  id                          :integer          not null, primary key
#  event_id                    :integer          not null
#  opens_at                    :datetime         not null
#  closes_at                   :datetime         not null
#  blind_review                :boolean          default(FALSE), not null
#  max_submissions_per_speaker :integer          default(3), not null
#  guidelines                  :text
#  tracks                      :text
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

module Cfp
  class Window < ActiveRecord::Base
    belongs_to :event, inverse_of: :cfp_window

    validates :opens_at, presence: true
    validates :closes_at, presence: true
    validates :max_submissions_per_speaker, numericality: { only_integer: true, greater_than: 0 }
    validate :closes_after_opens

    attr_readonly :event_id

    scope :open_at, ->(time) { where('opens_at <= ? AND closes_at >= ?', time, time) }

    def status(now = Time.current)
      if now < opens_at
        :upcoming
      elsif now > closes_at
        :closed
      else
        :open
      end
    end

    def open?(now = Time.current)
      status(now) == :open
    end

    def upcoming?(now = Time.current)
      status(now) == :upcoming
    end

    def closed?(now = Time.current)
      status(now) == :closed
    end

    def track_list
      tracks.to_s.lines.map(&:strip).compact_blank
    end

    private

    def closes_after_opens
      return if opens_at.blank? || closes_at.blank?
      return if closes_at > opens_at

      errors.add :closes_at, 'should be after opening time'
    end
  end
end
