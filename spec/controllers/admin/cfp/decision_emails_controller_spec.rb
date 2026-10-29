# frozen_string_literal: true

require 'spec_helper'

describe Admin::Cfp::DecisionEmailsController do
  stub_current_user

  let(:event) { create :event }

  describe 'GET new' do
    it 'builds the default template for the given status with a preview' do
      proposal = create :accepted_cfp_proposal, event: event
      _rejected = create :cfp_proposal, event: event, status: 'rejected'

      get :new, params: { event_id: event.id, status: 'accepted' }

      expect(assigns[:form]).to have_attributes status: 'accepted', subject: Cfp::DecisionEmailForm::TEMPLATES['accepted'][:subject]
      expect(assigns[:recipients]).to eq [proposal]
      expect(assigns[:preview]).to eq proposal
    end

    it 'defaults to accepted' do
      get :new, params: { event_id: event.id }
      expect(assigns[:form].status).to eq 'accepted'
      expect(assigns[:preview]).to be_nil
    end
  end

  describe 'POST create' do
    let(:email_params) { { status: 'rejected', subject: 'Sorry {{speaker_name}}', body: 'No {{proposal_title}}' } }

    before do
      allow(Cfp::SendDecisionsJob).to receive(:perform_later)
    end

    it 'renders the preview without sending' do
      proposal = create :cfp_proposal, event: event, status: 'rejected'

      post :create, params: { event_id: event.id, preview: 'Preview', decision_email: email_params }

      expect(controller).to render :new
      expect(assigns[:preview]).to eq proposal
      expect(Cfp::SendDecisionsJob).not_to have_received(:perform_later)
    end

    it 'renders new when the form is invalid' do
      post :create, params: { event_id: event.id, decision_email: email_params.merge(subject: '') }
      expect(controller).to render :new
      expect(assigns[:form].errors[:subject]).to be_present
      expect(Cfp::SendDecisionsJob).not_to have_received(:perform_later)
    end

    it 'enqueues the job and redirects' do
      create :cfp_proposal, event: event, status: 'rejected'

      post :create, params: { event_id: event.id, decision_email: email_params }

      expect(Cfp::SendDecisionsJob).to have_received(:perform_later)
        .with(event.id, 'rejected', 'Sorry {{speaker_name}}', 'No {{proposal_title}}')
      expect(controller).to redirect_to admin_event_cfp_proposals_path(event)
      expect(flash[:notice]).to eq 'Sending 1 decision emails'
    end
  end

  context 'when signed in as reviewer' do
    stub_current_user role: :reviewer

    it 'is forbidden' do
      get :new, params: { event_id: event.id }
      expect(controller).to render 'admin/shared/forbidden', status: :forbidden
    end
  end
end
