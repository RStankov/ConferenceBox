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
#  tickets_url                        :string
#  sponsors_announced                 :boolean          default(FALSE), not null
#

class Event < ActiveRecord::Base
  belongs_to :conference, inverse_of: :events

  has_many :sessions, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_many :photos, dependent: :destroy

  has_and_belongs_to_many :sponsors

  has_one_attached :logo
  has_one_attached :share_image
  has_one_attached :coverart

  validates :name, presence: true
  validates :date, presence: true

  validate :ensure_current_event_is_visible

  after_save :ensure_only_one_current_event_in_conference, if: :current?

  attr_readonly :conference_id

  scope :publicly_announced, -> { order('date DESC').where publicly_announced: true }

  default_scope -> { order('name DESC') }

  delegate :domain, to: :conference

  def full_name
    "#{conference.name} #{name}"
  end

  private

  def ensure_current_event_is_visible
    errors.add :current, 'should be publicly announced' if current? && !publicly_announced?
  end

  def ensure_only_one_current_event_in_conference
    conference.events.where('id != ? AND current', id).update_all current: false
  end
end
