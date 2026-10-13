# frozen_string_literal: true

class Admin::Cfp::WindowsController < Admin::BaseController
  def new
    @event = find_event
    @window = @event.build_cfp_window opens_at: Time.current.beginning_of_day, closes_at: 1.month.from_now.end_of_day
  end

  def create
    @event = find_event
    @window = @event.create_cfp_window window_params
    respond_with @window, location: admin_event_path(@event)
  end

  def edit
    @event = find_event
    @window = @event.cfp_window
  end

  def update
    @event = find_event
    @window = @event.cfp_window
    @window.update window_params
    respond_with @window, location: admin_event_path(@event)
  end

  def destroy
    @event = find_event
    @window = @event.cfp_window.destroy
    respond_with @window, location: admin_event_path(@event)
  end

  private

  def find_event
    Event.find params[:event_id]
  end

  def window_params
    params.require(:cfp_window).permit(
      :opens_at,
      :closes_at,
      :blind_review,
      :max_submissions_per_speaker,
      :guidelines,
      :tracks,
    )
  end
end
