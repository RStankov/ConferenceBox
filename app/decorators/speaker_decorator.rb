# frozen_string_literal: true

class SpeakerDecorator < Draper::Decorator
  decorates :speaker
  delegate_all

  SOCIAL_LINKS = {
    twitter_account:   ['twitter', 'https://twitter.com/%s'],
    github_account:    ['github', 'https://github.com/%s'],
    facebook_account:  ['facebook', 'https://facebook.com/%s'],
    instagram_account: ['instagram', 'https://instagram.com/%s'],
    dribbble_account:  ['dribbble', 'https://dribbble.com/%s'],
    personal_site:     ['site', '%s'],
  }.freeze

  def social_links
    SOCIAL_LINKS.map do |key, (type, mask)|
      link = object.public_send key
      [type, mask % link] if link.present?
    end.compact
  end

  def ordered_sessions
    sessions.announced.reorder 'id ASC'
  end
end
