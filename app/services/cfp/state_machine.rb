# frozen_string_literal: true

module Cfp
  class InvalidTransition < StandardError
  end

  module StateMachine
    extend self

    TRANSITIONS = {
      'draft'        => %w(submitted withdrawn),
      'submitted'    => %w(under_review accepted rejected waitlisted withdrawn),
      'under_review' => %w(accepted rejected waitlisted withdrawn),
      'waitlisted'   => %w(accepted rejected withdrawn),
      'accepted'     => %w(confirmed declined),
      'rejected'     => [],
      'confirmed'    => [],
      'declined'     => [],
      'withdrawn'    => [],
    }.freeze

    TIMESTAMPS = {
      'submitted'  => :submitted_at,
      'accepted'   => :decided_at,
      'rejected'   => :decided_at,
      'waitlisted' => :decided_at,
      'confirmed'  => :responded_at,
      'declined'   => :responded_at,
    }.freeze

    def allowed_transitions(proposal)
      TRANSITIONS.fetch proposal.status
    end

    def can_transition?(proposal, to)
      allowed_transitions(proposal).include? to.to_s
    end

    def transition(proposal, to, user: nil, note: nil)
      to = to.to_s

      unless can_transition?(proposal, to)
        raise InvalidTransition, "proposal #{proposal.id} cannot move from #{proposal.status} to #{to}"
      end

      Proposal.transaction do
        from = proposal.status
        attributes = { status: to }
        attributes[TIMESTAMPS[to]] = Time.current if TIMESTAMPS[to]

        proposal.update! attributes
        proposal.status_changes.create! from_status: from, to_status: to, user: user, note: note
      end

      proposal
    end
  end
end
