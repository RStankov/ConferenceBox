# frozen_string_literal: true

# == Schema Information
#
# Table name: session_speakers
#
#  id         :integer          not null, primary key
#  speaker_id :integer          not null
#  session_id :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class SessionSpeaker < ActiveRecord::Base
  belongs_to :speaker
  belongs_to :session

  validates :speaker, presence: true
  validates :session, presence: true
  validates :speaker_id, uniqueness: { scope: :session_id }
end
