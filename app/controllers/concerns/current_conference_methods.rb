# frozen_string_literal: true

module CurrentConferenceMethods
  extend ActiveSupport::Concern

  included do
    helper_method :current_conference
    before_action :set_view_path
  end

  private

  def current_conference
    @current_conference ||= if Rails.env.development?
                              params[:domain] ? Conference.find_for_domain(params[:domain]) : Conference.first
                            else
                              Conference.find_for_domain(request.domain)
                            end
  end

  def set_view_path
    prepend_view_path "#{Rails.root}/app/views/themes/#{current_conference.theme}"
  end
end
