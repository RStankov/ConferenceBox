# frozen_string_literal: true

require 'spec_helper'

describe Cfp::ProposalSpeaker do
  it 'normalises the email before validation' do
    speaker = create :cfp_proposal_speaker, email: '  Jane@Example.ORG '
    expect(speaker.email).to eq 'jane@example.org'
  end

  it 'requires name and a valid email' do
    speaker = build :cfp_proposal_speaker, name: '', email: 'nope'

    expect(speaker).to have_error_on :name
    expect(speaker).to have_error_on :email
  end

  it 'allows one record per email per proposal' do
    existing = create :cfp_proposal_speaker, email: 'jane@example.org'
    duplicate = build :cfp_proposal_speaker, proposal: existing.proposal, email: 'JANE@example.org'
    other = build :cfp_proposal_speaker, email: 'jane@example.org'

    expect(duplicate).to have_error_on :email
    expect(other).to be_valid
  end

  describe '.primary' do
    it 'returns only primary contacts' do
      proposal = create :cfp_proposal
      secondary = create :cfp_proposal_speaker, proposal: proposal

      expect(proposal.speakers.primary).not_to include secondary
      expect(proposal.speakers.primary.count).to eq 1
    end
  end

  describe '#link_list' do
    it 'splits links by line and ignores blanks' do
      speaker = build :cfp_proposal_speaker, links: " https://a.example \n\nhttps://b.example\n"
      expect(speaker.link_list).to eq %w(https://a.example https://b.example)
    end

    it 'is empty without links' do
      expect(build(:cfp_proposal_speaker, links: nil).link_list).to eq []
    end
  end
end
