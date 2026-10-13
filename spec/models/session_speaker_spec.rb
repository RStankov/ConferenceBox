# frozen_string_literal: true

require 'spec_helper'

describe SessionSpeaker do
  it 'can be created' do
    expect(create(:session_speaker)).to be_persisted
  end
end
