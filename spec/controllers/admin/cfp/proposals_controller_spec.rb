# frozen_string_literal: true

require 'spec_helper'

describe Admin::Cfp::ProposalsController do
  stub_current_user

  let(:event) { create :event }

  describe 'GET index' do
    it 'assigns submitted proposals and status counts' do
      submitted = create :cfp_proposal, event: event
      accepted = create :accepted_cfp_proposal, event: event
      _draft = create :draft_cfp_proposal, event: event
      _other = create :cfp_proposal

      get :index, params: { event_id: event.id }

      expect(assigns[:event]).to eq event
      expect(assigns[:proposals]).to contain_exactly submitted, accepted
      expect(assigns[:status_counts]).to eq 'submitted' => 1, 'accepted' => 1
      expect(assigns[:window]).to be_nil
    end

    it 'passes the filters to Cfp::FilterProposals' do
      allow(Cfp::FilterProposals).to receive(:call).and_call_original
      get :index, params: { event_id: event.id, status: 'accepted', sort: 'title' }
      expect(Cfp::FilterProposals).to have_received(:call) do |scope, params|
        expect(scope).to eq event.cfp_proposals
        expect(params[:status]).to eq 'accepted'
        expect(params[:sort]).to eq 'title'
      end
    end

    it 'sends a csv export' do
      allow(controller).to receive(:render).and_call_original
      create :cfp_proposal, event: event, title: 'Exported talk'
      get :index, params: { event_id: event.id }, format: :csv
      expect(response.media_type).to eq 'text/csv'
      expect(response.headers['Content-Disposition']).to include "#{event.name.parameterize}-proposals.csv"
      expect(response.body).to include Cfp::ProposalsCsv::HEADERS.first
      expect(response.body).to include 'Exported talk'
    end
  end

  describe 'GET show' do
    let(:proposal) { create :cfp_proposal, event: event }

    it 'assigns the proposal with its reviews, assignments, comments and timeline' do
      reviewer = create :user
      other_user = create :user
      review = create :cfp_review, proposal: proposal, reviewer: reviewer, score: 4
      assignment = create :cfp_review_assignment, proposal: proposal, reviewer: reviewer
      comment = create :cfp_comment, proposal: proposal, user: other_user
      change = Cfp::StateMachine.transition proposal, :under_review, user: other_user

      get :show, params: { event_id: event.id, id: proposal.id }

      expect(assigns[:proposal]).to be_a Cfp::ProposalDecorator
      expect(assigns[:proposal].object).to eq proposal
      expect(assigns[:stats].total).to eq 1
      expect(assigns[:stats].mean).to eq 4.0
      expect(assigns[:reviews]).to eq [review]
      expect(assigns[:assignments]).to eq [assignment]
      expect(assigns[:assignable_reviewers]).to include other_user
      expect(assigns[:assignable_reviewers]).not_to include reviewer
      expect(assigns[:comments]).to eq [comment]
      expect(assigns[:status_changes]).to eq change.status_changes.to_a
      expect(assigns[:comment]).to be_a_new Cfp::Comment
    end

    it 'raises for proposals from another event' do
      other = create :cfp_proposal
      expect { get :show, params: { event_id: event.id, id: other.id } }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context 'when signed in as reviewer' do
    stub_current_user role: :reviewer

    it 'is forbidden' do
      get :index, params: { event_id: event.id }
      expect(controller).to render 'admin/shared/forbidden', status: :forbidden
    end
  end
end
