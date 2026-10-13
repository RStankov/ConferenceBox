# frozen_string_literal: true

require 'spec_helper'
require 'csv'

describe Cfp::ProposalsCsv do
  it 'starts with the headers' do
    rows = CSV.parse described_class.call(Cfp::Proposal.all)
    expect(rows).to eq [described_class::HEADERS]
  end

  it 'has one row per proposal with speaker details and score stats' do
    proposal = create :cfp_proposal, title: 'Talk', track: 'Backend', speaker_name: 'Jane', speaker_email: 'jane@example.org'
    proposal.speakers.first.update! company: 'ACME'
    create :cfp_review, proposal: proposal, score: 3
    create :cfp_review, proposal: proposal, score: 5
    other = create :cfp_proposal, title: 'Other'

    rows = CSV.parse described_class.call(Cfp::Proposal.where(id: [proposal.id, other.id]).order(:id))

    expect(rows.size).to eq 3
    expect(rows[1]).to eq [
      proposal.id.to_s, 'Talk', 'submitted', 'talk', 'intermediate', 'Backend', '30',
      'Jane', 'jane@example.org', 'ACME', '2', '4.0', '4.0', '1.0', proposal.submitted_at.iso8601
    ]
    expect(rows[2][7..10]).to eq ['Jane Speaker', other.speakers.first.email, nil, '0']
  end
end
