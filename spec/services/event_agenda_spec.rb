# frozen_string_literal: true

require 'spec_helper'

describe EventAgenda do
  def time(value)
    Time.new(2013, 6, 20, *value.split(':').map(&:to_i), 0, '+03:00')
  end

  it 'builds slots with breaks between sessions' do
    event = create :event
    create :session, event: event, title: 'Opening', start_at: '09:00', end_at: '09:30'
    create :session, event: event, title: 'Keynote', start_at: '10:00', end_at: '10:45'

    agenda = EventAgenda.for(event)

    expect(agenda.map(&:title)).to eq %w(Opening Break Keynote)
    expect(agenda.starts_at).to eq time('09:00')
    expect(agenda.ends_at).to eq time('10:45')
  end

  it 'falls back to the next session start when end time is missing' do
    event = create :event
    create :session, event: event, title: 'First', start_at: '09:00'
    create :session, event: event, title: 'Second', start_at: '09:40'

    first = EventAgenda.for(event).first

    expect(first.ends_at).to eq time('09:40')
  end

  it 'finds what is playing now and what is next' do
    event = create :event
    keynote = create :session, event: event, start_at: '09:00', end_at: '10:00'
    lunch_talk = create :session, event: event, start_at: '12:00', end_at: '12:30'

    agenda = EventAgenda.for(event)

    expect(agenda.now_playing(time('09:15')).map(&:session)).to eq [keynote]
    expect(agenda.up_next(time('09:15')).session).to eq lunch_talk
  end

  it 'detects a speaker booked in two tracks at the same time' do
    event = create :event
    speaker = create :speaker
    first = create :session, event: event, track: 1, start_at: '09:00', end_at: '10:00'
    second = create :session, event: event, track: 2, start_at: '09:30', end_at: '10:30'
    create :session_speaker, session: first, speaker: speaker
    create :session_speaker, session: second, speaker: speaker

    conflicts = EventAgenda.for(event).overlapping_speakers

    expect(conflicts.map { |a, b, speakers| [a.session, b.session, speakers] }).to eq [[first, second, [speaker]]]
  end
end
