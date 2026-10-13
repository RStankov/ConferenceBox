# frozen_string_literal: true

require 'spec_helper'

describe Cfp::StateMachine do
  describe '.allowed_transitions' do
    it 'lists the next statuses for the current one' do
      expect(described_class.allowed_transitions(build(:draft_cfp_proposal))).to eq %w(submitted withdrawn)
      expect(described_class.allowed_transitions(build(:cfp_proposal, status: 'rejected'))).to eq []
    end
  end

  describe '.can_transition?' do
    it 'accepts symbols and strings' do
      proposal = build :cfp_proposal, status: 'under_review'

      expect(described_class.can_transition?(proposal, :accepted)).to be true
      expect(described_class.can_transition?(proposal, 'rejected')).to be true
      expect(described_class.can_transition?(proposal, :confirmed)).to be false
    end
  end

  describe '.transition' do
    it 'changes the status' do
      proposal = create :cfp_proposal, status: 'under_review'

      described_class.transition proposal, :accepted

      expect(proposal.reload.status).to eq 'accepted'
    end

    it 'stamps submitted_at when submitting' do
      proposal = create :draft_cfp_proposal, title: 'T', abstract: 'A', format: 'talk'

      described_class.transition proposal, :submitted

      expect(proposal.reload.submitted_at).to be_within(1.second).of(Time.current)
    end

    it 'stamps decided_at on decisions' do
      proposal = create :cfp_proposal, status: 'under_review'

      described_class.transition proposal, :waitlisted

      expect(proposal.reload.decided_at).to be_within(1.second).of(Time.current)
    end

    it 'does not stamp decided_at for other transitions' do
      proposal = create :cfp_proposal

      described_class.transition proposal, :under_review

      expect(proposal.reload.decided_at).to be_nil
    end

    it 'records a status change with user and note' do
      proposal = create :cfp_proposal, status: 'under_review'
      user = create :user

      described_class.transition proposal, :rejected, user: user, note: 'Off topic'

      change = proposal.status_changes.last
      expect(change.from_status).to eq 'under_review'
      expect(change.to_status).to eq 'rejected'
      expect(change.user).to eq user
      expect(change.note).to eq 'Off topic'
    end

    it 'raises and leaves the record untouched on an invalid transition' do
      proposal = create :cfp_proposal, status: 'rejected'

      expect { described_class.transition proposal, :accepted }.to raise_error Cfp::InvalidTransition

      expect(proposal.reload.status).to eq 'rejected'
      expect(proposal.status_changes).to be_empty
    end

    it 'returns the proposal' do
      proposal = create :cfp_proposal
      expect(described_class.transition(proposal, :withdrawn)).to eq proposal
    end
  end
end
