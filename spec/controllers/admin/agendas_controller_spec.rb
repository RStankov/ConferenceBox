# frozen_string_literal: true

require 'spec_helper'

describe Admin::AgendasController do
  stub_current_user

  it 'shows the agenda with conflicts' do
    event = create :event
    speaker = create :speaker
    first = create :session, event: event, track: 1, start_at: '09:00', end_at: '10:00'
    second = create :session, event: event, track: 2, start_at: '09:30', end_at: '10:30'
    create :session_speaker, session: first, speaker: speaker
    create :session_speaker, session: second, speaker: speaker

    get :show, params: { event_id: event.id }

    expect(assigns[:conflicts].size).to eq 1
  end

  it 'shifts sessions in a track' do
    event = create :event
    early = create :session, event: event, track: 1, start_at: '09:00', end_at: '09:45'
    late = create :session, event: event, track: 1, start_at: '10:00', end_at: '10:45'

    patch :shift, params: { event_id: event.id, track: 1, from: '10:00', minutes: 30 }

    expect(early.reload).to have_attributes(start_at: '09:00', end_at: '09:45')
    expect(late.reload).to have_attributes(start_at: '10:30', end_at: '11:15')
  end
end
