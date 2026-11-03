# frozen_string_literal: true

class SpeakerProfile
  STOP_WORDS = %w(a an and the of in on for to with how why what from your our is are).freeze
  TOPIC_LIMIT = 5

  private_constant :STOP_WORDS

  attr_reader :speaker

  def initialize(speaker)
    @speaker = speaker
  end

  def talks_count
    sessions.size
  end

  def events
    sessions.map(&:event).uniq.sort_by(&:date).reverse
  end

  def first_appearance
    events.last
  end

  def returning?
    events.size > 1
  end

  def co_speakers
    sessions.flat_map(&:speakers).uniq - [speaker]
  end

  def topics
    words = sessions.flat_map { |session| keywords(session.title) }
    words.tally.sort_by { |word, count| [-count, word] }.first(TOPIC_LIMIT).map(&:first)
  end

  def media_coverage
    return 0 if sessions.empty?

    covered = sessions.count { |session| recorded?(session) }
    (covered.to_f / sessions.size * 100).round
  end

  def similar_speakers(limit: 3)
    candidates = Speaker.where.not(id: speaker.id)

    candidates
      .map { |other| [other, similarity(other)] }
      .select { |_, score| score.positive? }
      .sort_by { |_, score| -score }
      .first(limit)
      .map(&:first)
  end

  def summary
    parts = []
    parts << "#{talks_count} #{'talk'.pluralize(talks_count)}"
    parts << "since #{first_appearance.date.year}" if first_appearance
    parts << "on #{topics.first(2).join(' and ')}" if topics.any?
    parts.join(' ')
  end

  protected

  def topic_set
    @topic_set ||= topics.to_set
  end

  private

  def sessions
    @sessions ||= speaker.sessions.announced.includes(:event).to_a
  end

  def keywords(text)
    text.to_s.downcase.scan(/[[:alnum:]+#.]+/).reject { |word| word.size < 3 || STOP_WORDS.include?(word) }
  end

  def recorded?(session)
    session.video_url? || session.slides_url?
  rescue StandardError
    false
  end

  def similarity(other)
    other_profile = SpeakerProfile.new(other)
    (topic_set & other_profile.topic_set).size
  end
end
