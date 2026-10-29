# frozen_string_literal: true

require 'spec_helper'

describe Cfp::ConfirmationsController do
  stub_current_conference

  let(:event) { create :event }
  let(:proposal) { create :accepted_cfp_proposal, event: event }
  let(:speaker) { proposal.speakers.first }

  before do
    allow(controller).to receive(:current_event).and_return EventDecorator.decorate(event)
  end

  describe 'GET new' do
    it 'assigns a confirmation form' do
      get :new, params: { submission_token: proposal.token }

      expect(assigns[:form]).to be_a Cfp::ConfirmationForm
    end

    it 'redirects when the proposal is not accepted' do
      proposal.update! status: 'submitted'

      get :new, params: { submission_token: proposal.token }

      expect(controller).to redirect_to cfp_submission_path(proposal.token)
      expect(flash[:alert]).to eq 'This proposal is not waiting for a confirmation'
    end

    it 'raises on an unknown token' do
      expect { get :new, params: { submission_token: 'nope' } }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe 'POST create' do
    it 'confirms the proposal' do
      post :create, params: {
        submission_token: proposal.token,
        confirmation: { speakers: { speaker.id => {
          photo: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/speaker_photo.jpg'),
                                              'image/jpeg'), tshirt_size: 'S'
        } } },
      }

      expect(proposal.reload).to be_confirmed
      expect(controller).to redirect_to cfp_submission_path(proposal.token)
    end

    it 'renders new when details are missing' do
      post :create, params: { submission_token: proposal.token }

      expect(controller).to render :new
      expect(proposal.reload).to be_accepted
    end
  end

  describe 'POST decline' do
    it 'declines with the note from the speaker' do
      post :decline, params: { submission_token: proposal.token, reason: 'Visa did not come through' }

      expect(proposal.reload).to be_declined
      expect(proposal.status_changes.last.note).to eq 'Visa did not come through'
      expect(controller).to redirect_to cfp_submission_path(proposal.token)
    end
  end
end
