# frozen_string_literal: true

require 'spec_helper'

describe Admin::Cfp::PromotionsController do
  stub_current_user

  describe 'POST create' do
    it 'promotes the proposal and redirects to the new session' do
      proposal = create :accepted_cfp_proposal
      session = create :session, event: proposal.event
      allow(Cfp::PromoteToSession).to receive(:call).with(proposal).and_return session

      post :create, params: { proposal_id: proposal.id }

      expect(Cfp::PromoteToSession).to have_received(:call).with(proposal)
      expect(controller).to redirect_to edit_admin_session_path(session)
      expect(flash[:notice]).to eq 'Session created from the proposal, now pick a time slot'
    end

    it 'creates a real session from an accepted proposal' do
      proposal = create :accepted_cfp_proposal, title: 'Promoted talk'

      post :create, params: { proposal_id: proposal.id }

      expect(proposal.reload.session).to have_attributes title: 'Promoted talk'
      expect(controller).to redirect_to edit_admin_session_path(proposal.session)
    end

    it 'alerts when the proposal cannot be promoted' do
      proposal = create :cfp_proposal

      post :create, params: { proposal_id: proposal.id }

      expect(proposal.reload.session).to be_nil
      expect(controller).to redirect_to admin_event_cfp_proposal_path(proposal.event, proposal)
      expect(flash[:alert]).to eq 'only accepted proposals can be promoted'
    end
  end

  context 'when signed in as reviewer' do
    stub_current_user role: :reviewer

    it 'is forbidden' do
      post :create, params: { proposal_id: create(:accepted_cfp_proposal).id }
      expect(controller).to render 'admin/shared/forbidden', status: :forbidden
    end
  end
end
