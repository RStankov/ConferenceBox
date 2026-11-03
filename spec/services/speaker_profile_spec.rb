# frozen_string_literal: true

require 'spec_helper'

describe SpeakerProfile do
  def talk(speaker, title:, event: create(:event, sessions_announced: true), **attributes)
    session = create :session, event: event, title: title, **attributes
    create :session_speaker, session: session, speaker: speaker
    session
  end

  it 'summarizes talks and topics' do
    speaker = create :speaker
    talk speaker, title: 'Ruby on Rails at scale'
    talk speaker, title: 'Testing Ruby code', event: create(:event, name: '2014', date: Date.new(2014, 6, 20), sessions_announced: true)

    profile = SpeakerProfile.new(speaker)

    expect(profile).to have_attributes(
      talks_count: 2,
      returning?: true,
      topics: %w(ruby code rails scale testing),
      summary: '2 talks since 2013 on ruby and code',
    )
  end

  it 'calculates media coverage' do
    speaker = create :speaker
    talk speaker, title: 'Recorded', video_url: 'https://youtube.com/watch?v=1'
    talk speaker, title: 'Lost'

    expect(SpeakerProfile.new(speaker).media_coverage).to eq 50
  end

  it 'finds co-speakers and similar speakers' do
    speaker = create :speaker, name: 'Ann'
    partner = create :speaker, name: 'Bob'
    similar = create :speaker, name: 'Carl'
    create :speaker, name: 'Dan'

    shared = talk speaker, title: 'Pairing on JavaScript'
    create :session_speaker, session: shared, speaker: partner
    talk similar, title: 'Modern JavaScript'

    profile = SpeakerProfile.new(speaker)

    expect(profile.co_speakers).to eq [partner]
    expect(profile.similar_speakers).to match_array [partner, similar]
  end
end
