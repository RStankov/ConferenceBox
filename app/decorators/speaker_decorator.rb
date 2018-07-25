# frozen_string_literal: true

class SpeakerDecorator < Draper::Decorator
  decorates :speaker
  delegate_all

  SOCIAL_LINKS = {
    twitter_account:   'twitter',
    github_account:    'github',
    facebook_account:  'facebook',
    instagram_account: 'instagram',
    linkedin_account:  'linked-in',
    dribbble_account:  'dribbble',
    personal_site:     'site',
  }.freeze

  def social_links
    SOCIAL_LINKS.map do |key, type|
      link = object.public_send key
      [type, link] if link.present?
    end.compact
  end

  def ordered_sessions
    sessions.announced.reorder 'id ASC'
  end
end
