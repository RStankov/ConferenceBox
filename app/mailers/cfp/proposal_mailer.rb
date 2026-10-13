# frozen_string_literal: true

module Cfp
  class ProposalMailer < ApplicationMailer
    def received(proposal)
      @proposal = proposal
      @event = proposal.event
      @link = cfp_submission_url(proposal.token, host: @event.domain)

      mail(
        to: proposal.primary_speaker.email,
        from: sender(@event),
        subject: "We received your proposal: #{proposal.title}",
      )
    end

    def decision(proposal, subject, body)
      @body = body

      mail(
        to: proposal.speakers.map(&:email),
        from: sender(proposal.event),
        subject: subject,
      )
    end

    private

    def sender(event)
      event.conference.contact_email.presence || self.class.default[:from]
    end
  end
end
