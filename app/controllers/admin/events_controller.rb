# frozen_string_literal: true

class Admin::EventsController < Admin::BaseController
  def index
    @conference = Conference.find(params[:conference_id]) if params[:conference_id]
    @events = @conference ? @conference.events : Event.all
  end

  def new
    @event = Event.new conference_id: params[:conference_id]
  end

  def create
    @event = Event.create event_params
    respond_with @event, location: admin_events_path
  end

  def show
    @event = Event.find event_id
  end

  def edit
    @event = Event.find event_id
  end

  def update
    @event = Event.update event_id, event_params
    respond_with @event, location: admin_event_path(@event)
  end

  def destroy
    @event = Event.destroy event_id
    respond_with @event, location: admin_events_path
  end

  private

  def event_id
    params[:id]
  end

  def event_params
    params.require(:event).permit(
      :after_party_announced,
      :after_party_venue_address,
      :after_party_venue_map_embedded_url,
      :after_party_venue_map_url,
      :after_party_venue_name,
      :after_party_venue_notes,
      :after_party_venue_site_url,
      :call_to_papers_url,
      :color,
      :conference_id,
      :coverart,
      :current,
      :date,
      :dates_announced,
      :event_url,
      :logo,
      :name,
      :publicly_announced,
      :sessions_announced,
      :share_image,
      :show_coverart,
      :show_feedback_form,
      :show_photo_gallery,
      :show_streaming,
      :speakers_announced,
      :sponsors_announced,
      :streaming_code,
      :tickets_url,
      :town,
      :venue_address,
      :venue_announced,
      :venue_map_embedded_url,
      :venue_map_url,
      :venue_name,
      :venue_notes,
      :venue_site_url,
      sponsor_ids: [],
    )
  end
end
