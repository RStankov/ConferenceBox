# frozen_string_literal: true

require 'spec_helper'

describe Admin::Cfp::ReviewsController do
  let(:current_user) { create :reviewer }
  let(:proposal) { create :cfp_proposal, status: 'under_review' }

  before do
    allow(controller).to receive(:current_user).and_return current_user
  end

  describe 'GET index' do
    it 'lists own active assignments on reviewable proposals' do
      mine = create :cfp_review_assignment, proposal: proposal, reviewer: current_user
      _conflict = create :cfp_review_assignment, reviewer: current_user, conflict_of_interest: true
      _decided = create :cfp_review_assignment, reviewer: current_user, proposal: create(:accepted_cfp_proposal)
      _other = create :cfp_review_assignment

      get :index

      expect(assigns[:assignments]).to eq [mine]
      expect(assigns[:total_count]).to eq 1
      expect(assigns[:pending_count]).to eq 1
    end

    it 'hides reviewed assignments with the unreviewed filter' do
      reviewed = create :cfp_review_assignment, proposal: proposal, reviewer: current_user
      create :cfp_review, proposal: proposal, reviewer: current_user
      pending = create :cfp_review_assignment, reviewer: current_user

      get :index, params: { filter: 'unreviewed' }

      expect(assigns[:assignments]).to eq [pending]
      expect(assigns[:assignments]).not_to include reviewed
      expect(assigns[:total_count]).to eq 2
      expect(assigns[:pending_count]).to eq 1
    end

    it 'exports the queue as csv' do
      allow(controller).to receive(:render).and_call_original
      create :cfp_review_assignment, proposal: proposal, reviewer: current_user

      get :index, format: :csv

      expect(response.media_type).to eq 'text/csv'
      expect(response.headers['Content-Disposition']).to include 'review-queue.csv'
      expect(response.body).to include proposal.title
    end

    it 'is not forbidden for reviewers' do
      get :index
      expect(controller).not_to render 'admin/shared/forbidden', status: :forbidden
    end
  end

  describe 'GET show' do
    it 'assigns the proposal, a new review, the assignment and comments' do
      assignment = create :cfp_review_assignment, proposal: proposal, reviewer: current_user
      comment = create :cfp_comment, proposal: proposal

      get :show, params: { proposal_id: proposal.id }

      expect(assigns[:proposal]).to be_a Cfp::ProposalDecorator
      expect(assigns[:proposal].object).to eq proposal
      expect(assigns[:review]).to be_a_new Cfp::Review
      expect(assigns[:review].reviewer).to eq current_user
      expect(assigns[:assignment]).to eq assignment
      expect(assigns[:comments]).to eq [comment]
      expect(assigns[:comment]).to be_a_new Cfp::Comment
    end

    it 'assigns the existing review' do
      review = create :cfp_review, proposal: proposal, reviewer: current_user
      get :show, params: { proposal_id: proposal.id }
      expect(assigns[:review]).to eq review
    end

    it 'hides speakers for reviewers when blind review is on' do
      create :cfp_window, event: proposal.event, blind_review: true
      get :show, params: { proposal_id: proposal.id }
      expect(assigns[:proposal]).to be_blind
    end

    it 'shows speakers when blind review is off' do
      create :cfp_window, event: proposal.event, blind_review: false
      get :show, params: { proposal_id: proposal.id }
      expect(assigns[:proposal]).not_to be_blind
    end
  end

  describe 'POST create' do
    it 'saves the review and redirects to the queue' do
      post :create, params: { proposal_id: proposal.id, review: { score: 5, confidence: 3, comment: 'Great' } }

      review = proposal.reviews.find_by!(reviewer: current_user)
      expect(review).to have_attributes score: 5, confidence: 3, comment: 'Great'
      expect(controller).to redirect_to admin_cfp_reviews_path
      expect(flash[:notice]).to eq 'Review saved'
    end

    it 'renders show when the review is invalid' do
      post :create, params: { proposal_id: proposal.id, review: { score: 9, confidence: 3 } }

      expect(proposal.reviews).to be_empty
      expect(controller).to render :show
      expect(assigns[:review].errors[:score]).to be_present
      expect(assigns[:comment]).to be_a_new Cfp::Comment
    end
  end

  describe 'PATCH update' do
    it 'updates the existing review' do
      review = create :cfp_review, proposal: proposal, reviewer: current_user, score: 2

      patch :update, params: { proposal_id: proposal.id, review: { score: 4, confidence: 1, comment: 'Changed my mind' } }

      expect(review.reload).to have_attributes score: 4, confidence: 1, comment: 'Changed my mind'
      expect(controller).to redirect_to admin_cfp_reviews_path
    end

    it 'raises when there is no review yet' do
      expect do
        patch :update, params: { proposal_id: proposal.id, review: { score: 4, confidence: 1 } }
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe 'POST conflict' do
    it 'flags the assignment and redirects to the queue' do
      assignment = create :cfp_review_assignment, proposal: proposal, reviewer: current_user

      post :conflict, params: { proposal_id: proposal.id }

      expect(assignment.reload).to be_conflict_of_interest
      expect(controller).to redirect_to admin_cfp_reviews_path
      expect(flash[:notice]).to eq 'Thanks for flagging the conflict, the proposal is removed from your queue'
    end

    it 'raises without an assignment' do
      expect { post :conflict, params: { proposal_id: proposal.id } }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
