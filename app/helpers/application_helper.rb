# frozen_string_literal: true

module ApplicationHelper
  def markdown(text)
    RenderMarkdown.to_html(text).html_safe
  end

  def copyright
    "© #{Date.today.year}."
  end

  def new_line_to_break(text)
    return '' if text.blank?
    text = h(text)
    raw text.gsub(/[\r]*[\n]/, '<br>').strip
  end

  def render_in_layout(&block)
    content_for :content, &block
    render template: 'layouts/application'
  end

  def with_event(event)
    yield EventDecorator.decorate(event)
  end

  def with_speaker(speaker)
    yield SpeakerDecorator.decorate(speaker)
  end

  def conference_url(conference)
    "http://#{conference.domain}"
  end

  def current_event_path(options = {})
    event_path current_event, options
  end

  def event_path(event, options = {})
    if event.current?
      root_path options
    else
      archive_url event.name, options.merge(domain: event.domain)
    end
  end

  def attachment_image_tag(attachment, height: nil, size: nil, **args)
    return unless attachment.attached?

    image_tag Attachment.resize(attachment, height: height, size: size), size: size, height: height, **args
  end
end
