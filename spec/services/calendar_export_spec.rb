# frozen_string_literal: true

require 'spec_helper'

describe CalendarExport do
  it 'exports announced sessions as calendar events' do
    event = create :event, venue_name: 'Sofia Tech Park'
    create :session, event: event, title: 'Opening; welcome', start_at: '09:00', end_at: '09:30'

    ics = CalendarExport.call(event)

    expect(ics).to start_with "BEGIN:VCALENDAR\r\n"
    expect(ics).to include 'SUMMARY:Opening\; welcome'
    expect(ics).to include 'DTSTART:20130620T060000Z'
    expect(ics).to include 'LOCATION:Sofia Tech Park'
  end

  it 'builds a filename from the conference and event' do
    event = build :event, name: '2013', conference: build(:conference, name: 'IT Tour')

    expect(CalendarExport.filename(event)).to eq 'it-tour-2013.ics'
  end
end
