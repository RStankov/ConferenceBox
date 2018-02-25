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

    if size.present?
      image_tag attachment.variant(smart_resize(size * 2)), size: size, **args
    elsif height.present?
      image_tag attachment.variant(resize: "x#{height * 2}"), height: height, **args
    else
      image_tag attachment, args
    end
  end

  private

  def smart_resize(size)
    { resize: "#{size}x#{size}^", gravity: 'center', crop: "#{size}x#{size}+0+0" }
  end
end
