# frozen_string_literal: true

class Admin::FeedbacksController < Admin::BaseController
  def index
    @event = Event.find params[:event_id]
    @feedbacks = @event.feedbacks.newest.page(params[:page])
  end

  def destroy
    feedback = Feedback.destroy params[:id]
    redirect_to admin_event_feedbacks_path(event_id: feedback.event_id), notice: 'Feedback deleted successfully'
  end
end
