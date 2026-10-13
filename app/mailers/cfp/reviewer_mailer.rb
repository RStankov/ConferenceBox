# frozen_string_literal: true

module Cfp
  class ReviewerMailer < ApplicationMailer
    def reminder(reviewer, event, pending_count)
      @reviewer = reviewer
      @event = event
      @pending_count = pending_count
      @link = admin_cfp_reviews_url(host: event.domain, filter: 'unreviewed')

      mail(
        to: reviewer.email,
        from: event.conference.contact_email.presence || self.class.default[:from],
        subject: "#{pending_count} proposals are waiting for your review",
      )
    end
  end
end
