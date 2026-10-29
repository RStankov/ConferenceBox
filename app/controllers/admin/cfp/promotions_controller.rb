# frozen_string_literal: true

class Admin::Cfp::PromotionsController < Admin::BaseController
  def create
    proposal = Cfp::Proposal.find params[:proposal_id]
    session = Cfp::PromoteToSession.call proposal
    redirect_to edit_admin_session_path(session), notice: 'Session created from the proposal, now pick a time slot'
  rescue ArgumentError => e
    redirect_to admin_event_cfp_proposal_path(proposal.event_id, proposal), alert: e.message
  end
end
