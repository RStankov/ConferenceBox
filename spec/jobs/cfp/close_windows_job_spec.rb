# frozen_string_literal: true

require 'spec_helper'

describe Cfp::CloseWindowsJob do
  let(:closed_event) { create(:closed_cfp_window).event }

  it 'withdraws drafts of closed windows with a note' do
    draft = create :draft_cfp_proposal, event: closed_event

    described_class.perform_now

    expect(draft.reload.status).to eq 'withdrawn'
    expect(draft.status_changes.last.note).to eq 'Call for papers closed before the proposal was submitted'
  end

  it 'moves submitted proposals of closed windows to under review' do
    submitted = create :cfp_proposal, event: closed_event, status: 'submitted'

    described_class.perform_now

    expect(submitted.reload.status).to eq 'under_review'
    expect(submitted.status_changes.last.note).to eq 'Call for papers closed'
  end

  it 'leaves other statuses untouched' do
    accepted = create :accepted_cfp_proposal, event: closed_event
    under_review = create :cfp_proposal, event: closed_event, status: 'under_review'

    described_class.perform_now

    expect(accepted.reload.status).to eq 'accepted'
    expect(under_review.reload.status_changes).to be_empty
  end

  it 'ignores open and upcoming windows' do
    open_draft = create :draft_cfp_proposal, event: create(:cfp_window).event
    upcoming_submitted = create :cfp_proposal, event: create(:upcoming_cfp_window).event

    described_class.perform_now

    expect(open_draft.reload.status).to eq 'draft'
    expect(upcoming_submitted.reload.status).to eq 'submitted'
  end

  it 'is idempotent' do
    create :cfp_proposal, event: closed_event

    described_class.perform_now

    expect { described_class.perform_now }.not_to change(Cfp::StatusChange, :count)
  end
end
