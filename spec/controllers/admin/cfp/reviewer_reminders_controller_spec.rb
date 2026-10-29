# frozen_string_literal: true

require 'spec_helper'

describe Admin::Cfp::ReviewerRemindersController do
  stub_current_user

  describe 'POST create' do
    let(:event) { create :event }

    before do
      allow(Cfp::ReviewerReminderJob).to receive(:perform_later)
    end

    it 'enqueues the reminder job for the event' do
      post :create, params: { event_id: event.id }
      expect(Cfp::ReviewerReminderJob).to have_received(:perform_later).with(event.id)
    end

    it 'redirects to the proposals with a notice' do
      post :create, params: { event_id: event.id }
      expect(controller).to redirect_to admin_event_cfp_proposals_path(event)
      expect(flash[:notice]).to eq 'Reminders are on their way to reviewers with pending reviews'
    end
  end
end
