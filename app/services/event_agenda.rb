# frozen_string_literal: true

class EventAgenda
  include Enumerable

  TIME_ZONE = '+03:00'
  BREAK_THRESHOLD = 10.minutes
  DEFAULT_SESSION_LENGTH = 45.minutes

  private_constant :TIME_ZONE

  Slot = Struct.new(:session, :starts_at, :ends_at, :track, keyword_init: true) do
    def break?
      session.nil?
    end

    def duration
      ends_at - starts_at
    end

    def covers?(time)
      time >= starts_at && time < ends_at
    end

    def title
      break? ? 'Break' : session.title
    end
  end

  attr_reader :event

  def self.for(event)
    new(event).tap(&:build!)
  end

  def initialize(event)
    @event = event
    @slots = []
  end

  def build!
    @slots = sessions_by_track.flat_map { |track, sessions| slots_for_track(track, sessions) }
    self
  end

  def each(&block)
    @slots.each(&block)
  end

  def tracks
    @slots.map(&:track).uniq.sort
  end

  def now_playing(time = Time.current)
    @slots.reject(&:break?).select { |slot| slot.covers?(time) }
  end

  def up_next(time = Time.current)
    @slots.reject(&:break?).select { |slot| slot.starts_at > time }.min_by(&:starts_at)
  end

  def overlapping_speakers
    talks = @slots.reject(&:break?)

    talks.combination(2).filter_map do |a, b|
      next unless overlap?(a, b)

      shared = a.session.speakers & b.session.speakers
      [a, b, shared] if shared.any?
    end
  end

  def starts_at
    @slots.map(&:starts_at).min
  end

  def ends_at
    @slots.map(&:ends_at).max
  end

  def to_h
    {
      starts_at: starts_at&.iso8601,
      ends_at: ends_at&.iso8601,
      tracks: tracks,
      slots: map { |slot| serialize_slot(slot) },
    }
  end

  private

  attr_reader :slots

  def sessions_by_track
    event.sessions.includes(:speakers).group_by(&:track)
  end

  def slots_for_track(track, sessions)
    talks = sessions.sort_by(&:start_at).each_cons(2).map do |current, following|
      build_slot(current, track, fallback_end: parse_time(following.start_at))
    end
    talks << build_slot(sessions.last, track) if sessions.any?

    with_breaks(talks, track)
  end

  def build_slot(session, track, fallback_end: nil)
    starts_at = parse_time(session.start_at)
    ends_at = parse_time(session.end_at) || fallback_end || starts_at + DEFAULT_SESSION_LENGTH

    Slot.new(session: session, starts_at: starts_at, ends_at: ends_at, track: track)
  end

  def with_breaks(talks, track)
    talks.each_cons(2).each_with_object([talks.first]) do |(previous, current), result|
      gap = current.starts_at - previous.ends_at
      result << Slot.new(starts_at: previous.ends_at, ends_at: current.starts_at, track: track) if gap >= BREAK_THRESHOLD
      result << current
    end.compact
  end

  def overlap?(a, b)
    a.starts_at < b.ends_at && b.starts_at < a.ends_at
  end

  def parse_time(value)
    return if value.blank?

    hours, minutes = value.split(':').map(&:to_i)
    Time.new(event.date.year, event.date.month, event.date.day, hours, minutes, 0, TIME_ZONE)
  end

  def serialize_slot(slot)
    {
      id: slot.session&.id,
      title: slot.title,
      track: slot.track,
      break: slot.break?,
      starts_at: slot.starts_at.iso8601,
      ends_at: slot.ends_at.iso8601,
      speakers: slot.break? ? [] : slot.session.speakers.map(&:name),
    }
  end

  def legacy_minutes_between(a, b)
    ((b - a) / 60).round
  end
end
