# frozen_string_literal: true

class Admin::Cfp::ReviewsController < Admin::BaseController
  skip_before_action :require_organizer_access

  def index
    assignments = current_user.review_assignments.active.joins(:proposal).merge(Cfp::Proposal.reviewable)
    @total_count = assignments.count
    @pending_count = assignments.without_review.count
    assignments = assignments.without_review if params[:filter] == 'unreviewed'
    @assignments = assignments.includes(proposal: %i(event speakers)).order(assigned_at: :desc, id: :desc)

    respond_to do |format|
      format.html
      format.csv do
        proposals = Cfp::Proposal.where(id: assignments.select(:proposal_id))
        send_data Cfp::ProposalsCsv.call(proposals), filename: 'review-queue.csv'
      end
    end
  end

  def show
    @proposal = decorate find_proposal
    @review = @proposal.reviews.find_or_initialize_by reviewer: current_user
    load_review_page
  end

  def create
    @proposal = decorate find_proposal
    @review = @proposal.reviews.build review_params.merge(reviewer: current_user)
    save_review
  end

  def update
    @proposal = decorate find_proposal
    @review = @proposal.reviews.find_by! reviewer: current_user
    @review.assign_attributes review_params
    save_review
  end

  def conflict
    proposal = find_proposal
    assignment = proposal.review_assignments.find_by! reviewer: current_user
    assignment.update! conflict_of_interest: true
    redirect_to admin_cfp_reviews_path, notice: 'Thanks for flagging the conflict, the proposal is removed from your queue'
  end

  private

  def find_proposal
    Cfp::Proposal.find params[:proposal_id]
  end

  def decorate(proposal)
    Cfp::ProposalDecorator.decorate proposal, context: { blind: blind_review?(proposal) }
  end

  def blind_review?(proposal)
    return false if current_user.organizer_access?

    proposal.event.cfp_window&.blind_review? || false
  end

  def save_review
    if @review.save
      redirect_to admin_cfp_reviews_path, notice: 'Review saved'
    else
      load_review_page
      render :show
    end
  end

  def load_review_page
    @assignment = @proposal.review_assignments.find_by reviewer: current_user
    @comments = @proposal.comments.includes(:user).oldest
    @comment = Cfp::Comment.new
  end

  def review_params
    params.require(:review).permit(:score, :confidence, :comment)
  end
end
