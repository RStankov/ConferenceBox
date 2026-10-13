# frozen_string_literal: true

require 'spec_helper'

describe Cfp::AssignReviewers do
  let(:event) { create :event }

  it 'returns 0 when there are no users' do
    create :cfp_proposal, event: event
    expect(described_class.call(event)).to eq 0
  end

  it 'assigns the requested number of reviewers per proposal' do
    create_list :reviewer, 3
    proposal = create :cfp_proposal, event: event

    expect(described_class.call(event, per_proposal: 2)).to eq 2
    expect(proposal.review_assignments.count).to eq 2
  end

  it 'balances load using existing assignments' do
    busy = create :reviewer
    free = create :reviewer
    create :cfp_review_assignment, reviewer: busy
    create :cfp_review_assignment, reviewer: busy
    proposal = create :cfp_proposal, event: event

    described_class.call event, per_proposal: 1

    expect(proposal.reviewers).to eq [free]
  end

  it 'spreads proposals across reviewers' do
    create_list :reviewer, 2
    create_list :cfp_proposal, 4, event: event

    described_class.call event, per_proposal: 1

    counts = Cfp::ReviewAssignment.group(:reviewer_id).count.values
    expect(counts).to eq [2, 2]
  end

  it 'skips reviewers who are speakers on the proposal' do
    speaker_reviewer = create :reviewer, email: 'jane@example.org'
    other = create :reviewer
    proposal = create :cfp_proposal, event: event, speaker_email: 'Jane@Example.org'

    described_class.call event, per_proposal: 2

    expect(proposal.reviewers).to eq [other]
    expect(proposal.reviewers).not_to include speaker_reviewer
  end

  it 'does not duplicate existing assignments' do
    reviewer = create :reviewer
    proposal = create :cfp_proposal, event: event
    create :cfp_review_assignment, proposal: proposal, reviewer: reviewer

    expect(described_class.call(event, per_proposal: 1)).to eq 0
    expect(proposal.review_assignments.count).to eq 1
  end

  it 'moves submitted proposals to under review' do
    create :reviewer
    proposal = create :cfp_proposal, event: event, status: 'submitted'

    described_class.call event, per_proposal: 1

    expect(proposal.reload.status).to eq 'under_review'
    expect(proposal.status_changes.last.to_status).to eq 'under_review'
  end

  it 'ignores proposals that are not reviewable or belong to other events' do
    create :reviewer
    accepted = create :accepted_cfp_proposal, event: event
    other_event = create :cfp_proposal

    described_class.call event

    expect(accepted.review_assignments).to be_empty
    expect(other_event.review_assignments).to be_empty
  end
end
