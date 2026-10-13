# frozen_string_literal: true

module Cfp
  module DecideProposals
    extend self

    DECISIONS = {
      'accepted'   => 'accepted',
      'rejected'   => 'rejected',
      'waitlisted' => 'waitlisted',
    }.freeze

    def call(proposals, decision:, user:, note: nil)
      status = DECISIONS.fetch(decision.to_s) { raise ArgumentError, "unknown decision #{decision}" }

      Proposal.transaction do
        proposals.each { StateMachine.transition _1, status, user: user, note: note }
      end
    end
  end
end
