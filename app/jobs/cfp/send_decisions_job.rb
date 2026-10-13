# frozen_string_literal: true

module Cfp
  class SendDecisionsJob < ApplicationJob
    queue_as :default

    def perform(event_id, status, subject, body)
      event = Event.find event_id
      form = DecisionEmailForm.new status: status, subject: subject, body: body

      form.recipients(event).find_each do |proposal|
        ProposalMailer.decision(proposal, form.render_subject(proposal), form.render_body(proposal)).deliver_now
        proposal.update! decision_sent_at: Time.current
      end
    end
  end
end
