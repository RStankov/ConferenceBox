# frozen_string_literal: true

require 'spec_helper'

describe Cfp::SpeakerDetailsForm do
  let(:window) { create :cfp_window, max_submissions_per_speaker: 2 }

  def form(attributes = {})
    described_class.new window, { name: 'Jane', email: 'jane@example.org' }.merge(attributes)
  end

  it 'requires name and email' do
    form = form(name: '', email: '')

    expect(form).to have_error_on :name
    expect(form).to have_error_on :email
  end

  it 'requires a valid email' do
    expect(form(email: 'nope')).to have_error_on :email
  end

  describe 'submissions limit' do
    it 'rejects a speaker who reached the limit' do
      create_list :cfp_proposal, 2, event: window.event, speaker_email: 'jane@example.org'

      expect(form(email: 'jane@example.org')).to have_error_on :email, 'has already submitted the maximum of 2 proposals'
    end

    it 'compares emails case insensitively' do
      create_list :cfp_proposal, 2, event: window.event, speaker_email: 'jane@example.org'

      expect(form(email: ' JANE@example.org ')).to have_error_on :email
    end

    it 'does not count withdrawn proposals' do
      create :cfp_proposal, event: window.event, speaker_email: 'jane@example.org'
      create :cfp_proposal, event: window.event, speaker_email: 'jane@example.org', status: 'withdrawn'

      expect(form).to be_valid
    end

    it 'does not count proposals for other events' do
      create_list :cfp_proposal, 2, speaker_email: 'jane@example.org'

      expect(form).to be_valid
    end
  end

  describe '#save' do
    it 'creates a draft proposal with a primary speaker' do
      form = form(company: 'ACME', bio: 'Bio', links: 'https://jane.example')

      expect(form.save).to be true

      proposal = form.proposal
      expect(proposal).to be_draft
      expect(proposal.event).to eq window.event
      expect(proposal.primary_speaker).to have_attributes(
        name: 'Jane',
        email: 'jane@example.org',
        company: 'ACME',
        bio: 'Bio',
        links: 'https://jane.example',
      )
    end

    it 'does nothing when invalid' do
      expect(form(name: '').save).to be false
      expect(Cfp::Proposal.count).to eq 0
    end
  end
end
