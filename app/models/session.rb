# frozen_string_literal: true
# == Schema Information
#
# Table name: sessions
#
#  id          :integer          not null, primary key
#  event_id    :integer          not null
#  start_at    :string(255)      not null
#  title       :string(255)      not null
#  slides_url  :string(255)
#  video_url   :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  track       :integer          default(1), not null
#  end_at      :string
#  description :text
#
# Foreign Keys
#
#  sessions_event_id_fk  (event_id => events.id)
#

class Session < ActiveRecord::Base
  belongs_to :event

  has_many :session_speakers, dependent: :destroy
  has_many :speakers, through: :session_speakers

  validates :title, presence: true
  validates :track, numericality: { only_integer: true, allow_nil: false }
  validates :start_at, presence: true, format: { with: /\A[0-9]{2}:[0-9]{2}\Z/ }

  attr_readonly :event_id

  default_scope -> { order 'start_at ASC' }

  scope :announced, -> { joins(:event).where('events.sessions_announced' => true) }

  delegate :full_name, to: :event, prefix: true

  class << self
    def by_track
      all.group_by(&:track)
    end
  end
end
