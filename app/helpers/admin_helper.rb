# frozen_string_literal: true

module AdminHelper
  def actions(&block)
    content_for :actions, &block
  end

  def upload_input(form, field_name)
    attachment = form.object.public_send(field_name)
    preview_tag = image_preview attachment if attachment.attached?
    input = form.input(field_name, as: :file, label: false, wrapper_html: { style: 'display: block !important;' })

    field_set_tag field_name.to_s.humanize do
      "#{preview_tag}#{input}".html_safe
    end
  end

  def badge(content, type: :primary)
    content_tag :mark, content, class: "badge badge-#{type}"
  end

  def admin_form_for(record, options = {}, &block)
    options[:builder] ||= AdminFormBuilder
    simple_form_for record, options, &block
  end

  def action_link(text, path, options = {})
    options[:class] = 'btn btn-light'
    link_to text, path, options
  end

  def edit_action(path)
    action_link 'Edit', path
  end

  def delete_action(path)
    action_link 'Delete', path, method: :delete, 'data-confirm' => 'Are you sure?'
  end

  private

  def image_preview(attachment)
    content_tag :div, link_to(image_tag(attachment.variant(resize: '50x'), width: 50), attachment, target: :blank)
  end

  class AdminFormBuilder < SimpleForm::FormBuilder
    def field_set(title = nil, &block)
      @template.field_set_tag title, class: 'form-group', &block
    end

    def buttons(cancel_path: nil)
      html = button(:submit, 'Submit')
      html << @template.link_to('Cancel', cancel_path, class: 'btn btn-light') if cancel_path
      html
    end

    def image_input(field_name, options = {})
      attachment = object.public_send(field_name)
      preview_tag = image_preview attachment if attachment.attached?
      input_tag = input field_name, as: :file, label: false, wrapper_html: { style: 'display: block !important; margin: 0;' }

      html = label field_name, "#{options[:label] || field_name.to_s.humanize}:", class: 'control-label'
      html << @template.content_tag(:div, "#{preview_tag}#{input_tag}".html_safe, class: 'form-control p-2', style: 'height: 100%')

      @template.content_tag :div, html, class: 'form-group'
    end

    private

    def image_preview(attachment)
      image_tag = @template.image_tag(attachment.variant(resize: 'x50'), height: 50, class: 'img-thumbnail')
      link_tag = @template.link_to image_tag, attachment, target: :blank
      @template.content_tag :div, link_tag, class: 'mb-2'
    end
  end
end
