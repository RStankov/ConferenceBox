# frozen_string_literal: true

module ScheduleHelper
  def render_schedule_json(event)
    EventSerializer.new(event).to_json
  end

  class EventSerializer
    attr_reader :event

    def initialize(event)
      @event = event
    end

    def as_json(_options = {})
      return {} unless event.sessions_announced?

      {
        sessions: sessions,
        sponsors: sponsors
      }
    end

    private

    def sessions
      return [] unless event.sessions_announced?
      event.sessions.map { |s| SessionSerializer.new(s) }.group_by(&:track)
    end

    def sponsors
      return [] unless event.sponsors_announced?
      event.sponsors.map { |s| SponsorSerializer.new(s) }
    end
  end

  class SessionSerializer
    attr_reader :session

    delegate :track, to: :session

    def initialize(session)
      @session = session
    end

    def as_json(_options = {})
      {
        title: session.title,
        startTime: time(session.start_at),
        endTime: time(session.end_at),
        speakers: speakers
      }
    end

    private

    def time(hour)
      return unless hour.present?
      hour, minute = hour.split(':')
      date = session.event.date
      Time.new(date.year, date.month, date.day, hour.to_i, minute.to_i)
    end

    def speakers
      session.speakers.map do |speaker|
        {
          name: speaker.name,
          avatarUrl: Attachment.url(speaker.photo, size: 350),
        }
      end
    end
  end

  class SponsorSerializer
    attr_reader :sponsor

    def initialize(sponsor)
      @sponsor = sponsor
    end

    def as_json(_options = {})
      {
        url: sponsor.website_url,
        logoUrl: Attachment.url(sponsor.logo, height: 60)
      }
    end
  end
end
