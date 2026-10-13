# frozen_string_literal: true

class Admin::Cfp::AssignmentsController < Admin::BaseController
  def auto
    event = Event.find params[:event_id]
    created = Cfp::AssignReviewers.call event, per_proposal: params.fetch(:per_proposal, Cfp::AssignReviewers::DEFAULT_PER_PROPOSAL).to_i
    redirect_to admin_event_cfp_proposals_path(event), notice: "Created #{created} review assignments"
  end

  def create
    proposal = Cfp::Proposal.find params[:proposal_id]
    assignment = proposal.review_assignments.create reviewer_id: params.require(:assignment).fetch(:reviewer_id)

    if assignment.persisted?
      Cfp::StateMachine.transition(proposal, :under_review, user: current_user) if proposal.submitted?
      redirect_to proposal_path(proposal), notice: 'Reviewer assigned'
    else
      redirect_to proposal_path(proposal), alert: assignment.errors.full_messages.to_sentence
    end
  end

  def destroy
    proposal = Cfp::Proposal.find params[:proposal_id]
    proposal.review_assignments.destroy params[:id]
    redirect_to proposal_path(proposal), notice: 'Reviewer unassigned'
  end

  private

  def proposal_path(proposal)
    admin_event_cfp_proposal_path proposal.event_id, proposal
  end
end
