# frozen_string_literal: true

class Admin::Cfp::ReviewerRemindersController < Admin::BaseController
  def create
    event = Event.find params[:event_id]
    Cfp::ReviewerReminderJob.perform_later event.id
    redirect_to admin_event_cfp_proposals_path(event), notice: 'Reminders are on their way to reviewers with pending reviews'
  end
end
