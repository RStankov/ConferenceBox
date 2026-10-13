# frozen_string_literal: true

module Cfp
  module AssignReviewers
    extend self

    DEFAULT_PER_PROPOSAL = 2

    def call(event, per_proposal: DEFAULT_PER_PROPOSAL)
      reviewers = User.reviewers.to_a
      return 0 if reviewers.empty?

      load = ReviewAssignment.active.where(reviewer_id: reviewers.map(&:id)).group(:reviewer_id).count
      load.default = 0
      created = 0

      Proposal.transaction do
        event.cfp_proposals.reviewable.includes(:speakers, :review_assignments).find_each do |proposal|
          created += assign(proposal, reviewers, load, per_proposal)
        end
      end

      created
    end

    private

    def assign(proposal, reviewers, load, per_proposal)
      assigned_ids = proposal.review_assignments.map(&:reviewer_id)
      missing = per_proposal - assigned_ids.size
      return 0 if missing <= 0

      picked = pick(proposal, reviewers, load, assigned_ids, missing)

      picked.each do |reviewer|
        proposal.review_assignments.create! reviewer: reviewer
        load[reviewer.id] += 1
      end

      StateMachine.transition(proposal, :under_review) if proposal.submitted? && (assigned_ids + picked).any?

      picked.size
    end

    def pick(proposal, reviewers, load, assigned_ids, missing)
      candidates = reviewers.reject { assigned_ids.include?(_1.id) || conflict?(_1, proposal) }
      candidates.sort_by { [load[_1.id], _1.id] }.first(missing)
    end

    def conflict?(reviewer, proposal)
      proposal.speaker_emails.include? reviewer.email.downcase
    end
  end
end
