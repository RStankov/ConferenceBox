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
  belongs_to :speaker, inverse_of: :session_speakers
  belongs_to :session, inverse_of: :session_speakers

  validates :speaker_id, uniqueness: { scope: :session_id }
end
