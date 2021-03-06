# frozen_string_literal: true

module CurrentConferenceMethods
  extend ActiveSupport::Concern

  included do
    helper_method :current_conference
    helper_method :current_event
    before_action :set_view_path
  end

  private

  def current_conference
    @current_conference ||= if Rails.env.development? || Rails.env.test?
                              params[:domain] ? Conference.find_for_domain(params[:domain]) : Conference.first!
                            else
                              Conference.find_for_domain(request.domain)
                            end
  end

  def current_event
    @current_event ||= @event || EventDecorator.decorate(current_conference.current_event)
  end

  def set_view_path
    prepend_view_path "#{Rails.root}/app/views/themes/#{current_conference.theme}"
  end
end
