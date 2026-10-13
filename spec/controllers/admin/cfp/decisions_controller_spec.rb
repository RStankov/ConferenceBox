# frozen_string_literal: true

require 'spec_helper'

describe Admin::Cfp::DecisionsController do
  let(:current_user) { create :user }
  let(:event) { create :event }

  before do
    allow(controller).to receive(:current_user).and_return current_user
  end

  describe 'POST create' do
    it 'applies the decision to the selected proposals' do
      first = create :cfp_proposal, event: event
      second = create :cfp_proposal, event: event
      _skipped = create :cfp_proposal, event: event

      post :create, params: { event_id: event.id, proposal_ids: [first.id, second.id], decision: 'accepted', note: 'Strong' }

      expect(first.reload).to be_accepted
      expect(second.reload).to be_accepted
      expect(first.status_changes.last).to have_attributes user: current_user, note: 'Strong'
      expect(controller).to redirect_to admin_event_cfp_proposals_path(event)
      expect(flash[:notice]).to eq '2 proposals marked as accepted'
    end

    it 'delegates to Cfp::DecideProposals' do
      proposal = create :cfp_proposal, event: event
      allow(Cfp::DecideProposals).to receive(:call)

      post :create, params: { event_id: event.id, proposal_ids: [proposal.id], decision: 'rejected' }

      expect(Cfp::DecideProposals).to have_received(:call) do |proposals, decision:, user:, note:|
        expect(proposals).to eq [proposal]
        expect(decision).to eq 'rejected'
        expect(user).to eq current_user
        expect(note).to be_nil
      end
    end

    it 'redirects to return_to when given' do
      proposal = create :cfp_proposal, event: event
      path = admin_event_cfp_proposal_path(event, proposal)

      post :create, params: { event_id: event.id, proposal_ids: [proposal.id], decision: 'waitlisted', return_to: path }

      expect(controller).to redirect_to path
    end

    it 'ignores proposals from other events' do
      other = create :cfp_proposal

      post :create, params: { event_id: event.id, proposal_ids: [other.id], decision: 'accepted' }

      expect(other.reload).to be_submitted
      expect(flash[:alert]).to eq 'Select at least one proposal'
    end

    it 'alerts when nothing is selected' do
      post :create, params: { event_id: event.id, decision: 'accepted' }
      expect(controller).to redirect_to admin_event_cfp_proposals_path(event)
      expect(flash[:alert]).to eq 'Select at least one proposal'
    end

    it 'alerts on invalid transitions' do
      proposal = create :accepted_cfp_proposal, event: event

      post :create, params: { event_id: event.id, proposal_ids: [proposal.id], decision: 'rejected' }

      expect(proposal.reload).to be_accepted
      expect(controller).to redirect_to admin_event_cfp_proposals_path(event)
      expect(flash[:alert]).to include 'cannot move from accepted to rejected'
    end
  end
end
