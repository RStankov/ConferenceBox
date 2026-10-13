# frozen_string_literal: true

require 'spec_helper_features'

feature 'Speaker' do
  create_dummy_conference_event

  it 'showing speaker page' do
    speaker = create :speaker, description: 'description'

    visit speaker_path(speaker)

    expect(page).to have_text speaker.name
    expect(page).to have_text speaker.description
  end

  it 'showing speaker sessions' do
    event = create :event, sessions_announced: true

    speaker = create :speaker

    session1 = create :session, event: event, speakers: [speaker]
    session2 = create :session, event: event, speakers: [speaker]

    visit speaker_path(speaker)

    expect(page).to have_text session1.title
    expect(page).to have_text session2.title
  end
end
