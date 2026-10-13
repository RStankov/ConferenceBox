# frozen_string_literal: true

class Admin::Cfp::DecisionEmailsController < Admin::BaseController
  def new
    @event = find_event
    @form = Cfp::DecisionEmailForm.default_for params.fetch(:status, 'accepted')
    @recipients = @form.recipients(@event).to_a
    @preview = @recipients.first
  end

  def create
    @event = find_event
    @form = Cfp::DecisionEmailForm.new email_params
    @recipients = @form.recipients(@event).to_a
    @preview = @recipients.first

    if params[:preview].present? || !@form.valid?
      render :new
    else
      Cfp::SendDecisionsJob.perform_later @event.id, @form.status, @form.subject, @form.body
      redirect_to admin_event_cfp_proposals_path(@event), notice: "Sending #{@recipients.size} decision emails"
    end
  end

  private

  def find_event
    Event.find params[:event_id]
  end

  def email_params
    params.require(:decision_email).permit(:status, :subject, :body)
  end
end
