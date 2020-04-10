# frozen_string_literal: true

module RenderMarkdown
  extend self

  OPTIONS = {
    tables:              true,
    autolink:            true,
    superscript:         true,
    strikethrough:       true,
    no_intra_emphasis:   true,
    fenced_code_blocks:  true,
    space_after_headers: true,
  }.freeze

  RENDERER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, OPTIONS)

  def to_html(text)
    return '' if text.blank?

    RENDERER.render text
  end
end
