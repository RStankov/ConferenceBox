# frozen_string_literal: true

require 'spec_helper'

describe Cfp::DecideProposals do
  let(:user) { create :user }

  it 'applies the decision to every proposal with user and note' do
    proposals = create_list :cfp_proposal, 2, status: 'under_review'

    described_class.call proposals, decision: 'accepted', user: user, note: 'Great fit'

    proposals.each do |proposal|
      expect(proposal.reload.status).to eq 'accepted'
      expect(proposal.status_changes.last).to have_attributes user: user, note: 'Great fit'
    end
  end

  it 'accepts symbol decisions' do
    proposal = create :cfp_proposal

    described_class.call [proposal], decision: :rejected, user: user

    expect(proposal.reload.status).to eq 'rejected'
  end

  it 'raises on unknown decision' do
    expect { described_class.call [], decision: 'maybe', user: user }.to raise_error ArgumentError
  end

  it 'rolls back the whole batch when one transition is invalid' do
    valid = create :cfp_proposal, status: 'under_review'
    invalid = create :cfp_proposal, status: 'rejected'

    expect { described_class.call [valid, invalid], decision: 'accepted', user: user }.to raise_error Cfp::InvalidTransition

    expect(valid.reload.status).to eq 'under_review'
    expect(valid.status_changes).to be_empty
  end
end
