# frozen_string_literal: true

require 'spec_helper'

describe Admin::Cfp::AssignmentsController do
  let(:current_user) { create :user }
  let(:event) { create :event }
  let(:proposal) { create :cfp_proposal, event: event }
  let(:reviewer) { create :reviewer }

  before do
    allow(controller).to receive(:current_user).and_return current_user
  end

  describe 'POST auto' do
    before do
      allow(Cfp::AssignReviewers).to receive(:call).and_return 3
    end

    it 'auto-assigns with the default number of reviewers' do
      post :auto, params: { event_id: event.id }
      expect(Cfp::AssignReviewers).to have_received(:call).with(event, per_proposal: Cfp::AssignReviewers::DEFAULT_PER_PROPOSAL)
    end

    it 'auto-assigns with the given number of reviewers' do
      post :auto, params: { event_id: event.id, per_proposal: '3' }
      expect(Cfp::AssignReviewers).to have_received(:call).with(event, per_proposal: 3)
    end

    it 'redirects with the number of created assignments' do
      post :auto, params: { event_id: event.id }
      expect(controller).to redirect_to admin_event_cfp_proposals_path(event)
      expect(flash[:notice]).to eq 'Created 3 review assignments'
    end
  end

  describe 'POST create' do
    it 'assigns the reviewer and moves the proposal to review' do
      post :create, params: { proposal_id: proposal.id, assignment: { reviewer_id: reviewer.id } }

      expect(proposal.review_assignments.map(&:reviewer)).to eq [reviewer]
      expect(proposal.reload).to be_under_review
      expect(proposal.status_changes.last.user).to eq current_user
      expect(controller).to redirect_to admin_event_cfp_proposal_path(event, proposal)
      expect(flash[:notice]).to eq 'Reviewer assigned'
    end

    it 'leaves proposals already under review alone' do
      proposal.update! status: 'under_review'
      post :create, params: { proposal_id: proposal.id, assignment: { reviewer_id: reviewer.id } }
      expect(proposal.reload).to be_under_review
      expect(proposal.status_changes).to be_empty
    end

    it 'alerts on duplicate assignments' do
      create :cfp_review_assignment, proposal: proposal, reviewer: reviewer

      post :create, params: { proposal_id: proposal.id, assignment: { reviewer_id: reviewer.id } }

      expect(proposal.review_assignments.count).to eq 1
      expect(controller).to redirect_to admin_event_cfp_proposal_path(event, proposal)
      expect(flash[:alert]).to eq 'Reviewer has already been taken'
    end
  end

  describe 'DELETE destroy' do
    it 'removes the assignment' do
      assignment = create :cfp_review_assignment, proposal: proposal, reviewer: reviewer

      delete :destroy, params: { proposal_id: proposal.id, id: assignment.id }

      expect(proposal.review_assignments.reload).to be_empty
      expect(controller).to redirect_to admin_event_cfp_proposal_path(event, proposal)
      expect(flash[:notice]).to eq 'Reviewer unassigned'
    end
  end

  context 'when signed in as reviewer' do
    stub_current_user role: :reviewer

    it 'is forbidden' do
      post :auto, params: { event_id: event.id }
      expect(controller).to render 'admin/shared/forbidden', status: :forbidden
    end
  end
end
