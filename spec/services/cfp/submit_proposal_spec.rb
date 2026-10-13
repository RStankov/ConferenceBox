# frozen_string_literal: true

require 'spec_helper'

describe Cfp::SubmitProposal do
  before { ActionMailer::Base.deliveries.clear }

  let(:proposal) do
    create :draft_cfp_proposal, title: 'Talk', abstract: 'Abstract', format: 'talk', speaker_email: 'jane@example.org'
  end

  it 'moves the proposal to submitted' do
    described_class.call proposal

    expect(proposal.reload.status).to eq 'submitted'
    expect(proposal.submitted_at).to be_within(1.second).of(Time.current)
  end

  it 'sends the confirmation email to the primary speaker' do
    described_class.call proposal

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq ['jane@example.org']
    expect(mail.subject).to eq 'We received your proposal: Talk'
    expect(mail.body.encoded).to include proposal.token
  end

  it 'refuses to submit twice' do
    described_class.call proposal

    expect { described_class.call proposal }.to raise_error Cfp::InvalidTransition
    expect(ActionMailer::Base.deliveries.size).to eq 1
  end
end
