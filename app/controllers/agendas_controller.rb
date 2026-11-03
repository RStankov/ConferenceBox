# frozen_string_literal: true

class AgendasController < ApplicationController
  def show
    event = find_event

    respond_to do |format|
      format.ics do
        send_data CalendarExport.call(event), filename: CalendarExport.filename(event), type: 'text/calendar'
      end
      format.json do
        render json: agenda_payload(event)
      end
    end
  end

  private

  def find_event
    event = current_conference.announced_event_named(params[:id])
    raise ActiveRecord::RecordNotFound unless event.sessions_announced?

    event
  end

  def agenda_payload(event)
    agenda = EventAgenda.for(event)
    payload = agenda.to_h
    payload[:now_playing] = agenda.now_playing.map { |slot| slot.session.id }
    payload[:conflicts] = conflicts(agenda) if admin_preview?
    payload
  end

  def conflicts(agenda)
    agenda.overlapping_speakers.map do |a, b, speakers|
      { sessions: [a.session.id, b.session.id], speakers: speakers.map(&:name) }
    end
  end

  def admin_preview?
    params[:preview] == '1'
  end
end
