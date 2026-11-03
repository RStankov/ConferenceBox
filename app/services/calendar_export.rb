# frozen_string_literal: true

module CalendarExport
  extend self

  LINE_LIMIT = 75
  PRODUCT_ID = '-//ConferenceBox//Agenda//EN'

  def call(event, agenda: EventAgenda.for(event))
    lines = []
    lines << 'BEGIN:VCALENDAR'
    lines << 'VERSION:2.0'
    lines << "PRODID:#{PRODUCT_ID}"
    lines << "X-WR-CALNAME:#{escape(event.full_name)}"

    agenda.reject(&:break?).each do |slot|
      lines.concat vevent(event, slot)
    end

    lines << 'END:VCALENDAR'
    lines.map { |line| fold(line) }.join("\r\n") + "\r\n"
  end

  def filename(event)
    "#{event.conference.name.parameterize}-#{event.name.parameterize}.ics"
  end

  private

  def vevent(event, slot)
    [
      'BEGIN:VEVENT',
      "UID:session-#{slot.session.id}@#{event.domain}",
      "DTSTAMP:#{format_time(Time.current)}",
      "DTSTART:#{format_time(slot.starts_at)}",
      "DTEND:#{format_time(slot.ends_at)}",
      "SUMMARY:#{escape(slot.title)}",
      "DESCRIPTION:#{escape(description(slot))}",
      "LOCATION:#{escape(event.venue_name.to_s)}",
      'END:VEVENT',
    ]
  end

  def description(slot)
    speakers = slot.session.speakers.map(&:name).join(', ')
    [speakers.presence, slot.session.description].compact.join("\n\n")
  end

  def format_time(time)
    time.utc.strftime('%Y%m%dT%H%M%SZ')
  end

  def escape(text)
    text.to_s.gsub('\\', '\\\\\\\\').gsub(';', '\;').gsub("\n", '\n')
  end

  def fold(line)
    return line if line.bytesize <= LINE_LIMIT

    line.scan(/.{1,#{LINE_LIMIT - 1}}/).join("\r\n ")
  end
end
