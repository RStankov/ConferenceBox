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
end
