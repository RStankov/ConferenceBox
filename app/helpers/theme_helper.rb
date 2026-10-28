# frozen_string_literal: true

module ThemeHelper
  SOCIAL_ICONS = {
    'twitter'   => 'fa-twitter',
    'github'    => 'fa-github',
    'facebook'  => 'fa-facebook',
    'instagram' => 'fa-instagram',
    'linked-in' => 'fa-linkedin',
    'dribbble'  => 'fa-dribbble',
    'youtube'   => 'fa-youtube',
    'site'      => 'fa-external-link',
  }.freeze

  def theme_root_attributes(event)
    attributes = { lang: 'en', 'data-theme' => 'auto' }
    attributes[:style] = "--cb-accent: #{event.color};" if event.respond_to?(:color) && event.color.present?
    attributes
  end

  def social_icon_class(type)
    "fa #{SOCIAL_ICONS.fetch(type.to_s, 'fa-link')}"
  end

  def section_heading(title, label: nil, subtitle: nil)
    content_tag :header, class: 'cb-section-heading' do
      html = ActiveSupport::SafeBuffer.new
      html << content_tag(:span, label, class: 'cb-section-label') if label
      html << content_tag(:h2, title)
      html << content_tag(:p, subtitle, class: 'cb-section-subtitle') if subtitle
      html
    end
  end

  def conference_social_links(conference)
    [
      ['facebook', conference.facebook_account? && "https://www.facebook.com/#{conference.facebook_account}"],
      ['twitter', conference.twitter_account? && "https://twitter.com/#{conference.twitter_account}"],
      ['instagram', conference.instagram_account? && "https://instagram.com/#{conference.instagram_account}"],
      ['youtube', conference.youtube_account? && "https://youtube.com/#{conference.youtube_account}"],
    ].select(&:second)
  end

  def agenda_slot_tag(event, session, &block)
    content_tag :li, class: agenda_slot_classes(event, session), data: agenda_slot_data(event, session), &block
  end

  def agenda_break_tag(slot)
    content_tag :li, class: 'schedule-card schedule-card--break' do
      content_tag(:time, format_slot_range(slot)) + content_tag(:div, "#{slot.title} · #{(slot.duration / 60).round} min")
    end
  end

  def add_to_calendar_link(event, label: 'Добави в календара')
    return unless event.sessions_announced?

    link_to label, event.calendar_url, class: 'cb-button cb-button--ghost', download: true
  end

  private

  def agenda_slot_classes(event, session)
    classes = ['schedule-card']
    classes << 'schedule-card--now' if event.now_playing?(session)
    classes << 'schedule-card--has-video' if session.video_url?
    classes.join(' ')
  end

  def agenda_slot_data(event, session)
    slot = event.agenda.find { |s| s.session == session }
    return {} unless slot

    { starts_at: slot.starts_at.iso8601, ends_at: slot.ends_at.iso8601, now_playing: true }
  end

  def format_slot_range(slot)
    [slot.starts_at, slot.ends_at].map { |time| time.strftime('%H:%M') }.join(' – ')
  end
end
