# frozen_string_literal: true

require 'spec_helper'

describe Cfp::StatusChange do
  it 'requires a known to_status' do
    change = described_class.new proposal: build(:cfp_proposal), to_status: 'lost'
    expect(change).to have_error_on :to_status
  end

  it 'does not require a user' do
    change = described_class.new proposal: build(:cfp_proposal), to_status: 'submitted'
    expect(change).to be_valid
  end

  describe '#actor_name' do
    it 'is the user full name when present' do
      change = described_class.new user: build(:user, first_name: 'Ada', last_name: 'Lovelace')
      expect(change.actor_name).to eq 'Ada Lovelace'
    end

    it 'is Submitter without a user' do
      expect(described_class.new.actor_name).to eq 'Submitter'
    end
  end

  describe '.oldest' do
    it 'orders by id ascending' do
      proposal = create :cfp_proposal
      first = proposal.status_changes.create! to_status: 'submitted'
      second = proposal.status_changes.create! to_status: 'under_review'

      expect(proposal.status_changes.oldest).to eq [first, second]
    end
  end
end
