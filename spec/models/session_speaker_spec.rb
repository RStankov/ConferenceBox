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
# Indexes
#
#  index_session_speakers_on_speaker_id_and_session_id  (speaker_id,session_id) UNIQUE
#
# Foreign Keys
#
#  session_speakers_session_id_fk  (session_id => sessions.id)
#  session_speakers_speaker_id_fk  (speaker_id => speakers.id)
#

require 'spec_helper'

describe SessionSpeaker do
  it 'can be created' do
  end
end
