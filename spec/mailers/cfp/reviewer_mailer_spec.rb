# frozen_string_literal: true

require 'spec_helper'

describe Cfp::ReviewerMailer do
  describe '#reminder' do
    let(:conference) { create :conference, domain: 'conf.example.org', contact_email: 'team@example.org' }
    let(:event) { create :event, conference: conference }
    let(:reviewer) { create :reviewer, first_name: 'Grace', email: 'grace@example.org' }
    let(:mail) { described_class.reminder reviewer, event, 3 }

    it 'is sent to the reviewer' do
      expect(mail.to).to eq ['grace@example.org']
      expect(mail.from).to eq ['team@example.org']
      expect(mail.subject).to eq '3 proposals are waiting for your review'
    end

    it 'links to the unreviewed queue on the conference domain' do
      expect(mail.body.encoded).to include 'Hi Grace'
      expect(mail.body.encoded).to include '3 proposals'
      expect(mail.body.encoded).to include 'http://conf.example.org/admin/cfp/reviews?filter=unreviewed'
    end
  end
end
