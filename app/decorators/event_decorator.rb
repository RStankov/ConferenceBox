# frozen_string_literal: true

class EventDecorator < Draper::Decorator
  decorates :event
  delegate_all

  delegate(
    :about,
    :about?,
    :slogan,
    :slogan?,
    :analytics_code,
    :analytics_code?,
    :copyright,
    :twitter_account,
    :twitter_account?,
    :facebook_account,
    :facebook_account?,
    :instagram_account,
    :instagram_account?,
    :youtube_account,
    :youtube_account?,
    :contact_email,
    :contact_email?,
    :code_of_conduct_url,
    :code_of_conduct_url?,
    to: :conference,
  )

  delegate :name, to: :conference, prefix: true

  def copyright
    "© #{Date.today.year} #{conference.copyright}"
  end

  def logo?
    logo.attached?
  end

  def favicon_url
    logo.variant(resize: '50').service_url
  end

  def logo_url
    logo.service_url
  end

  def formatted_date
    h.l date, format: :long
  end

  def speakers
    sessions.map(&:speakers).flatten
  end

  def start_time_for_javascript
    start_time.rfc2822
  end

  def ongoing?
    Time.current.between? start_time, finish_time
  end

  def finished?
    Time.current > finish_time
  end

  def other_conference_events?
    other_conference_events.any?
  end

  def sessions_by_track
    @sessions_by_track ||= sessions.by_track
  end

  def multi_track?
    @sessions_by_track.count > 1
  end

  def other_conference_events
    @other_conference_events ||= conference.events.publicly_announced
  end

  def information
    information = []
    information << l(date, format: :long) if dates_announced?
    information << venue_name if venue_announced?
    information.join ', '
  end

  def show_call_to_papers?
    call_to_papers_url? && !sessions_announced?
  end

  def after_party_venue_map?
    after_party_venue_map_url? && after_party_venue_map_embedded_url?
  end

  def sections
    [
      ['dates', dates_announced?],
      ['venue', venue_announced?],
      ['schedule', sessions_announced?],
      ['speakers', speakers_announced?],
      ['after_party', after_party_announced?],
    ].select(&:second).map(&:first)
  end

  private

  def start_time
    session_time sessions.first
  end

  def finish_time
    session_time sessions.last
  end

  def session_time(session)
    start_at = session.try(:start_at) || ''
    hours, minutes = start_at.split ':'
    # FIXME: Add time zone to choose from in the admin interface?
    Time.new(date.year, date.month, date.day, hours, minutes, 0, '+03:00')
  end
end
