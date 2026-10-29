# frozen_string_literal: true

require 'spec_helper'

describe Cfp::SubmissionsController do
  stub_current_conference

  let(:event) { create :event }
  let!(:window) { create :cfp_window, event: event, tracks: "Backend\nFrontend" }

  before do
    allow(controller).to receive(:current_event).and_return EventDecorator.decorate(event)
  end

  describe 'GET new' do
    it 'assigns a speaker details form' do
      get :new
      expect(assigns[:form]).to be_a Cfp::SpeakerDetailsForm
    end

    it 'redirects to the landing page when the window is closed' do
      window.update! opens_at: 2.months.ago, closes_at: 1.month.ago
      get :new
      expect(controller).to redirect_to cfp_path
      expect(flash[:alert]).to eq 'The call for papers is not open'
    end

    it 'redirects to the landing page when there is no window' do
      window.destroy!
      event.reload
      get :new
      expect(controller).to redirect_to cfp_path
    end
  end

  describe 'POST create' do
    it 'creates a draft proposal and redirects to the proposal step' do
      post :create, params: { speaker: { name: 'Jane', email: 'jane@example.org' } }

      proposal = Cfp::Proposal.last
      expect(proposal).to be_draft
      expect(proposal.primary_speaker.email).to eq 'jane@example.org'
      expect(controller).to redirect_to edit_cfp_submission_path(proposal.token)
    end

    it 'renders new when the form is invalid' do
      post :create, params: { speaker: { name: '', email: 'nope' } }
      expect(controller).to render :new
      expect(assigns[:form].errors[:name]).to be_present
      expect(Cfp::Proposal.count).to eq 0
    end
  end

  describe 'GET show' do
    it 'assigns the decorated proposal and the window' do
      proposal = create :cfp_proposal, event: event
      get :show, params: { token: proposal.token }
      expect(assigns[:proposal]).to be_a Cfp::ProposalDecorator
      expect(assigns[:proposal].object).to eq proposal
      expect(assigns[:window]).to eq window
    end

    it 'works when the window is closed' do
      proposal = create :cfp_proposal, event: event
      window.update! opens_at: 2.months.ago, closes_at: 1.month.ago
      get :show, params: { token: proposal.token }
      expect(assigns[:proposal].object).to eq proposal
    end

    it 'raises for proposals of other events' do
      proposal = create :cfp_proposal
      expect { get :show, params: { token: proposal.token } }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe 'GET edit' do
    it 'assigns a proposal details form' do
      proposal = create :draft_cfp_proposal, event: event
      get :edit, params: { token: proposal.token }
      expect(assigns[:proposal]).to eq proposal
      expect(assigns[:form]).to be_a Cfp::ProposalDetailsForm
    end

    it 'redirects when the proposal can no longer be changed' do
      proposal = create :accepted_cfp_proposal, event: event
      get :edit, params: { token: proposal.token }
      expect(controller).to redirect_to cfp_submission_path(proposal.token)
      expect(flash[:alert]).to eq 'This proposal can no longer be changed'
    end
  end

  describe 'PATCH update' do
    let(:proposal) { create :draft_cfp_proposal, event: event }
    let(:attributes) do
      { title: 'Title', abstract: 'Abstract', format: 'talk', level: 'beginner', track: 'Backend', duration_minutes: 30 }
    end

    it 'updates the proposal and redirects to the review step' do
      patch :update, params: { token: proposal.token, proposal: attributes }
      expect(proposal.reload.title).to eq 'Title'
      expect(controller).to redirect_to cfp_submission_path(proposal.token)
      expect(flash[:notice]).to eq 'Your proposal is saved'
    end

    it 'renders edit when the form is invalid' do
      patch :update, params: { token: proposal.token, proposal: attributes.merge(title: '') }
      expect(controller).to render :edit
      expect(proposal.reload.title).to be_nil
    end
  end

  describe 'POST submit' do
    it 'submits a complete draft' do
      proposal = create :draft_cfp_proposal, event: event
      proposal.update!(
        title: 'Title', abstract: 'Abstract', format: 'talk', level: 'beginner', track: 'Backend', duration_minutes: 30,
      )

      allow(Cfp::SubmitProposal).to receive(:call).and_call_original

      post :submit, params: { token: proposal.token }

      expect(Cfp::SubmitProposal).to have_received(:call).with(proposal)
      expect(proposal.reload).to be_submitted
      expect(controller).to redirect_to cfp_submission_path(proposal.token)
      expect(flash[:notice]).to eq 'Thanks! Your proposal is submitted'
    end

    it 'sends back to the proposal step when the draft is incomplete' do
      proposal = create :draft_cfp_proposal, event: event
      post :submit, params: { token: proposal.token }
      expect(proposal.reload).to be_draft
      expect(controller).to redirect_to edit_cfp_submission_path(proposal.token)
      expect(flash[:alert]).to eq 'Please complete your proposal before submitting'
    end

    it 'does not submit twice' do
      proposal = create :cfp_proposal, event: event
      post :submit, params: { token: proposal.token }
      expect(controller).to redirect_to edit_cfp_submission_path(proposal.token)
    end
  end

  describe 'POST withdraw' do
    it 'withdraws a submitted proposal' do
      proposal = create :cfp_proposal, event: event
      post :withdraw, params: { token: proposal.token }
      expect(proposal.reload).to be_withdrawn
      expect(proposal.status_changes.last.note).to eq 'Withdrawn by the submitter'
      expect(controller).to redirect_to cfp_submission_path(proposal.token)
      expect(flash[:notice]).to eq 'Your proposal is withdrawn'
    end

    it 'does not withdraw decided proposals' do
      proposal = create :accepted_cfp_proposal, event: event
      post :withdraw, params: { token: proposal.token }
      expect(proposal.reload).to be_accepted
      expect(flash[:alert]).to eq 'This proposal can no longer be changed'
    end
  end
end
