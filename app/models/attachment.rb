# frozen_string_literal: true

module Attachment
  extend self

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def resize(attachment, size: nil, width: nil, height: nil)
    return unless attachment.attached?

    if size.present?
      attachment.variant(smart_resize(size * 2, size * 2))
    elsif width.present? && height.present?
      attachment.variant(smart_resize(width * 2, height * 2))
    elsif width.present?
      attachment.variant(resize: "#{width * 2}x")
    elsif height.present?
      attachment.variant(resize: "x#{height * 2}")
    else
      attachment
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  def url(attachment, **args)
    variant = resize(attachment, **args)
    variant = variant.processed if variant.respond_to?(:processed)
    variant&.service_url
  end

  private

  def smart_resize(width, height)
    { resize: "#{width}x#{height}^", gravity: 'center', crop: "#{width}x#{height}+0+0" }
  end
end
