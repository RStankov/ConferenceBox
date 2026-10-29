# frozen_string_literal: true

require 'spec_helper'

describe Admin::Cfp::CommentsController do
  let(:proposal) { create :cfp_proposal }

  context 'when signed in as organizer' do
    let(:current_user) { create :organizer }

    before do
      allow(controller).to receive(:current_user).and_return current_user
    end

    it 'creates the comment and redirects to the proposal page' do
      post :create, params: { proposal_id: proposal.id, comment: { body: 'Nice one' } }

      expect(proposal.comments.last).to have_attributes body: 'Nice one', user: current_user
      expect(controller).to redirect_to admin_event_cfp_proposal_path(proposal.event, proposal)
      expect(flash[:notice]).to eq 'Comment added'
    end

    it 'alerts on blank comments' do
      post :create, params: { proposal_id: proposal.id, comment: { body: '' } }

      expect(proposal.comments).to be_empty
      expect(controller).to redirect_to admin_event_cfp_proposal_path(proposal.event, proposal)
      expect(flash[:alert]).to eq 'Comment cannot be blank'
    end
  end

  context 'when signed in as reviewer' do
    let(:current_user) { create :reviewer }

    before do
      allow(controller).to receive(:current_user).and_return current_user
    end

    it 'creates the comment on an assigned proposal and redirects to the review page' do
      create :cfp_review_assignment, proposal: proposal, reviewer: current_user

      post :create, params: { proposal_id: proposal.id, comment: { body: 'Question for the team' } }

      expect(proposal.comments.last).to have_attributes body: 'Question for the team', user: current_user
      expect(controller).to redirect_to admin_cfp_proposal_review_path(proposal)
    end

    it 'cannot comment on unassigned proposals' do
      expect do
        post :create, params: { proposal_id: proposal.id, comment: { body: 'Sneaky' } }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it 'cannot comment on proposals flagged as conflict' do
      create :cfp_review_assignment, proposal: proposal, reviewer: current_user, conflict_of_interest: true

      expect do
        post :create, params: { proposal_id: proposal.id, comment: { body: 'Sneaky' } }
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
