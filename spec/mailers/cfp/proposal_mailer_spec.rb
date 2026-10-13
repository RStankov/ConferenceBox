# frozen_string_literal: true

require 'spec_helper'

describe Cfp::ProposalMailer do
  let(:conference) { create :conference, domain: 'conf.example.org', contact_email: 'team@example.org' }
  let(:event) { create :event, conference: conference }

  describe '#received' do
    let(:proposal) do
      create :cfp_proposal, event: event, title: 'Talk', speaker_name: 'Jane', speaker_email: 'jane@example.org'
    end
    let(:mail) { described_class.received proposal }

    it 'is sent to the primary speaker from the conference contact' do
      expect(mail.to).to eq ['jane@example.org']
      expect(mail.from).to eq ['team@example.org']
      expect(mail.subject).to eq 'We received your proposal: Talk'
    end

    it 'includes the private link on the conference domain' do
      expect(mail.body.encoded).to include 'Hi Jane'
      expect(mail.body.encoded).to include "http://conf.example.org/cfp/submissions/#{proposal.token}"
    end

    it 'falls back to the default sender without a contact email' do
      conference.update! contact_email: nil

      expect(mail.from).to eq ['from@example.com']
    end
  end

  describe '#decision' do
    it 'is sent to all speakers with the given subject and body' do
      proposal = create :cfp_proposal, event: event, speaker_email: 'jane@example.org'
      proposal.speakers.create! name: 'Co', email: 'co@example.org'

      mail = described_class.decision proposal, 'Accepted!', 'Congratulations'

      expect(mail.to).to contain_exactly 'jane@example.org', 'co@example.org'
      expect(mail.from).to eq ['team@example.org']
      expect(mail.subject).to eq 'Accepted!'
      expect(mail.body.encoded).to include 'Congratulations'
    end
  end
end
