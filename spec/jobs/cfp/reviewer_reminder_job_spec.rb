# frozen_string_literal: true

require 'spec_helper'

describe Cfp::ReviewerReminderJob do
  let(:event) { create :event }

  before { ActionMailer::Base.deliveries.clear }

  it 'sends one reminder per reviewer with the pending count' do
    reviewer = create :reviewer, email: 'rev@example.org'
    create_list(:cfp_proposal, 2, event: event).each do |proposal|
      create :cfp_review_assignment, proposal: proposal, reviewer: reviewer
    end

    described_class.perform_now event.id

    expect(ActionMailer::Base.deliveries.size).to eq 1
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq ['rev@example.org']
    expect(mail.subject).to eq '2 proposals are waiting for your review'
  end

  it 'skips reviewers who already reviewed' do
    assignment = create :cfp_review_assignment, proposal: create(:cfp_proposal, event: event)
    create :cfp_review, proposal: assignment.proposal, reviewer: assignment.reviewer

    described_class.perform_now event.id

    expect(ActionMailer::Base.deliveries).to be_empty
  end

  it 'skips conflicts of interest' do
    create :cfp_review_assignment, proposal: create(:cfp_proposal, event: event), conflict_of_interest: true

    described_class.perform_now event.id

    expect(ActionMailer::Base.deliveries).to be_empty
  end

  it 'only counts reviewable proposals of the event' do
    reviewer = create :reviewer
    create :cfp_review_assignment, proposal: create(:accepted_cfp_proposal, event: event), reviewer: reviewer
    create :cfp_review_assignment, proposal: create(:cfp_proposal), reviewer: reviewer

    described_class.perform_now event.id

    expect(ActionMailer::Base.deliveries).to be_empty
  end
end
