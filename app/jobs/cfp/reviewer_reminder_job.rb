# frozen_string_literal: true

module Cfp
  class ReviewerReminderJob < ApplicationJob
    queue_as :default

    def perform(event_id)
      event = Event.find event_id

      pending = ReviewAssignment
                .active
                .without_review
                .joins(:proposal)
                .where(cfp_proposals: { event_id: event.id, status: Proposal::REVIEWABLE_STATUSES })
                .group(:reviewer_id)
                .count

      User.where(id: pending.keys).find_each do |reviewer|
        ReviewerMailer.reminder(reviewer, event, pending.fetch(reviewer.id)).deliver_now
      end
    end
  end
end
