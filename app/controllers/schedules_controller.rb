# frozen_string_literal: true

class SchedulesController < ApplicationController
  before_action :set_access_control_headers

  def index
    event = current_conference.current_event
    redirect_to schedule_path(event.name, format: :json)
  end

  def show
    if request.format.json?
      @event = current_conference.announced_event_named(params[:id])
    else
      redirect_to schedule_path(params[:id], format: :json)
    end
  end

  private

  def set_access_control_headers
    return unless request.format.json?

    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Request-Method'] = '*'
  end
end
