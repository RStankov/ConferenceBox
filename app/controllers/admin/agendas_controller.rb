# frozen_string_literal: true

class Admin::AgendasController < Admin::BaseController
  def show
    @event = Event.find params[:event_id]
    @agenda = EventAgenda.for(@event)
    @conflicts = @agenda.overlapping_speakers
    @gaps = long_breaks
  end

  def shift
    @event = Event.find params[:event_id]

    Session.transaction do
      sessions_to_shift.each do |session|
        session.update! start_at: shift_time(session.start_at), end_at: shift_time(session.end_at)
      end
    end

    redirect_to admin_event_agenda_path(@event), notice: "Shifted #{sessions_to_shift.size} sessions"
  end

  private

  def long_breaks
    @agenda.select { |slot| slot.break? && slot.duration > 90.minutes }
  end

  def sessions_to_shift
    @event.sessions.where(track: params[:track]).where('start_at >= ?', params[:from])
  end

  def shift_time(value)
    return value if value.blank?

    hours, minutes = value.split(':').map(&:to_i)
    total = hours * 60 + minutes + offset
    format('%02d:%02d', total / 60, total % 60)
  end

  def offset
    params[:minutes].to_i
  end
end
