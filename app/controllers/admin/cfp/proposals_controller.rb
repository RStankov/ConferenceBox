# frozen_string_literal: true

class Admin::Cfp::ProposalsController < Admin::BaseController
  PER_PAGE = 25

  def index
    @event = find_event
    @window = @event.cfp_window
    @status_counts = @event.cfp_proposals.submitted.group(:status).count
    @reviewers = User.all
    proposals = Cfp::FilterProposals.call(@event.cfp_proposals, params)

    respond_to do |format|
      format.html do
        @proposals = proposals.includes(:speakers).page(params[:page]).per(PER_PAGE)
      end
      format.csv do
        send_data Cfp::ProposalsCsv.call(proposals), filename: "#{@event.name.parameterize}-proposals.csv"
      end
    end
  end

  def show
    @event = find_event
    @proposal = Cfp::ProposalDecorator.decorate @event.cfp_proposals.find(params[:id])
    @stats = Cfp::ScoreAggregation.call([@proposal.object]).fetch(@proposal.id)
    @reviews = @proposal.reviews.includes(:reviewer).newest
    @assignments = @proposal.review_assignments.includes(:reviewer)
    @assignable_reviewers = User.where.not(id: @assignments.map(&:reviewer_id))
    @comments = @proposal.comments.includes(:user).oldest
    @status_changes = @proposal.status_changes.includes(:user).oldest
    @comment = Cfp::Comment.new
  end

  private

  def find_event
    Event.find params[:event_id]
  end
end
