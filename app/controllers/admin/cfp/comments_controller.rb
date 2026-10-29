# frozen_string_literal: true

class Admin::Cfp::CommentsController < Admin::BaseController
  skip_before_action :require_organizer_access

  def create
    proposal = accessible_proposals.find params[:proposal_id]
    comment = proposal.comments.create body: params.require(:comment).fetch(:body), user: current_user

    if comment.persisted?
      redirect_to return_path(proposal), notice: 'Comment added'
    else
      redirect_to return_path(proposal), alert: 'Comment cannot be blank'
    end
  end

  private

  def return_path(proposal)
    if current_user.organizer_access?
      admin_event_cfp_proposal_path proposal.event_id, proposal
    else
      admin_cfp_proposal_review_path proposal
    end
  end
end
