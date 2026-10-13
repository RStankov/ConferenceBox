# frozen_string_literal: true

require 'spec_helper'

describe Cfp::SendDecisionsJob do
  let(:event) { create :event, name: '2026', conference: create(:conference, name: 'RubyConf') }

  before { ActionMailer::Base.deliveries.clear }

  it 'emails every recipient with the interpolated template' do
    proposal = create :accepted_cfp_proposal, event: event, title: 'Talk', speaker_name: 'Jane',
                                                 speaker_email: 'jane@example.org'
    body = 'Hi {{speaker_name}}, welcome to {{event_name}}'

    described_class.perform_now event.id, 'accepted', 'Re: {{proposal_title}}', body

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq ['jane@example.org']
    expect(mail.subject).to eq 'Re: Talk'
    expect(mail.body.encoded).to include 'Hi Jane, welcome to RubyConf 2026'
    expect(proposal.reload.decision_sent_at).to be_within(1.second).of(Time.current)
  end

  it 'skips proposals that were already emailed or have another status' do
    _sent = create :accepted_cfp_proposal, event: event, decision_sent_at: 1.day.ago
    _rejected = create :cfp_proposal, event: event, status: 'rejected'
    pending = create :accepted_cfp_proposal, event: event

    described_class.perform_now event.id, 'accepted', 'Subject', 'Body'

    expect(ActionMailer::Base.deliveries.size).to eq 1
    expect(ActionMailer::Base.deliveries.last.to).to eq [pending.primary_speaker.email]
  end
end
