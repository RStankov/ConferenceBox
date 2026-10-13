# frozen_string_literal: true

class Admin::Cfp::DecisionsController < Admin::BaseController
  def create
    event = Event.find params[:event_id]
    proposals = event.cfp_proposals.where(id: params[:proposal_ids])

    if proposals.empty?
      redirect_to admin_event_cfp_proposals_path(event), alert: 'Select at least one proposal'
      return
    end

    Cfp::DecideProposals.call proposals, decision: params[:decision], user: current_user, note: params[:note]

    redirect_to return_path(event), notice: "#{pluralize_proposals proposals.size} marked as #{params[:decision]}"
  rescue Cfp::InvalidTransition => e
    redirect_to return_path(event), alert: e.message
  end

  private

  def return_path(event)
    params[:return_to].presence || admin_event_cfp_proposals_path(event)
  end

  def pluralize_proposals(count)
    ActionController::Base.helpers.pluralize count, 'proposal'
  end
end
