# frozen_string_literal: true

module AdminHelper
  def upload_input(form, field_name)
    attachment = form.object.public_send(field_name)
    preview = image_preview attachment if attachment.attached?
    input = form.input(:logo, as: :file, label: false, wrapper_html: { style: 'display: block !important;' })

    field_set_tag field_name.to_s.humanize do
      "#{preview}#{input}".html_safe
    end
  end

  private

  def image_preview(attachment)
    content_tag :div, link_to(image_tag(attachment.variant(resize: '50x'), width: 50), attachment, target: :blank)
  end
end
