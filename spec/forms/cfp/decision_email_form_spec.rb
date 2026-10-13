# frozen_string_literal: true

require 'spec_helper'

describe Cfp::DecisionEmailForm do
  describe '.default_for' do
    it 'loads the template for the status' do
      form = described_class.default_for 'rejected'

      expect(form.status).to eq 'rejected'
      expect(form.subject).to eq 'Update on your proposal for {{event_name}}'
      expect(form.body).to include 'could not fit yours'
    end

    it 'falls back to the accepted template' do
      form = described_class.default_for 'unknown'

      expect(form.subject).to eq described_class::TEMPLATES['accepted'][:subject]
    end
  end

  describe 'validations' do
    it 'requires a known status, subject and body' do
      form = described_class.new status: 'draft', subject: '', body: ''

      expect(form).to have_error_on :status
      expect(form).to have_error_on :subject
      expect(form).to have_error_on :body
    end
  end

  describe 'rendering' do
    let(:proposal) do
      event = create :event, name: '2026', conference: create(:conference, name: 'RubyConf')
      create :cfp_proposal, event: event, title: 'Talk', speaker_name: 'Jane'
    end

    it 'interpolates placeholders' do
      form = described_class.new subject: 'Re: {{ proposal_title }}', body: 'Hi {{speaker_name}}, see you at {{event_name}}'

      expect(form.render_subject(proposal)).to eq 'Re: Talk'
      expect(form.render_body(proposal)).to eq 'Hi Jane, see you at RubyConf 2026'
    end

    it 'blanks unknown placeholders' do
      form = described_class.new body: 'Hello {{nobody}}!'

      expect(form.render_body(proposal)).to eq 'Hello !'
    end
  end

  describe '#recipients' do
    it 'returns proposals with the status that have not been emailed' do
      event = create :event
      pending = create :accepted_cfp_proposal, event: event
      _sent = create :accepted_cfp_proposal, event: event, decision_sent_at: 1.day.ago
      _rejected = create :cfp_proposal, event: event, status: 'rejected'
      _other_event = create :accepted_cfp_proposal

      expect(described_class.new(status: 'accepted').recipients(event)).to eq [pending]
    end
  end
end
