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

require 'spec_helper'

describe SessionSpeaker do
  it 'can be created' do
  end
end
