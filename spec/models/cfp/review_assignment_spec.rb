# frozen_string_literal: true

require 'spec_helper'

describe Cfp::ReviewAssignment do
  it 'defaults assigned_at to now' do
    assignment = create :cfp_review_assignment
    expect(assignment.assigned_at).to be_within(1.second).of(Time.current)
  end

  it 'keeps an explicit assigned_at' do
    assignment = create :cfp_review_assignment, assigned_at: Time.zone.local(2026, 1, 1)
    expect(assignment.assigned_at).to eq Time.zone.local(2026, 1, 1)
  end

  it 'allows one assignment per reviewer per proposal' do
    existing = create :cfp_review_assignment
    duplicate = build :cfp_review_assignment, proposal: existing.proposal, reviewer: existing.reviewer

    expect(duplicate).to have_error_on :reviewer_id
  end

  describe '.active' do
    it 'excludes conflicts of interest' do
      active = create :cfp_review_assignment
      _conflict = create :cfp_review_assignment, conflict_of_interest: true

      expect(described_class.active).to eq [active]
    end
  end

  describe '.without_review' do
    it 'returns assignments whose reviewer has not reviewed the proposal' do
      pending = create :cfp_review_assignment
      reviewed = create :cfp_review_assignment
      create :cfp_review, proposal: reviewed.proposal, reviewer: reviewed.reviewer
      create :cfp_review, proposal: pending.proposal

      expect(described_class.without_review).to eq [pending]
    end
  end

  describe '#review' do
    it 'returns the review of the reviewer for the proposal' do
      assignment = create :cfp_review_assignment
      _other = create :cfp_review, proposal: assignment.proposal
      review = create :cfp_review, proposal: assignment.proposal, reviewer: assignment.reviewer

      expect(assignment.review).to eq review
    end

    it 'is nil without a review' do
      expect(create(:cfp_review_assignment).review).to be_nil
    end
  end
end
