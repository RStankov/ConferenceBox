# frozen_string_literal: true

# == Schema Information
#
# Table name: cfp_review_assignments
#
#  id                   :integer          not null, primary key
#  assigned_at          :datetime         not null
#  conflict_of_interest :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  proposal_id          :integer          not null
#  reviewer_id          :integer          not null
#
# Indexes
#
#  index_cfp_review_assignments_on_proposal_id                  (proposal_id)
#  index_cfp_review_assignments_on_proposal_id_and_reviewer_id  (proposal_id,reviewer_id) UNIQUE
#  index_cfp_review_assignments_on_reviewer_id                  (reviewer_id)
#
# Foreign Keys
#
#  proposal_id  (proposal_id => cfp_proposals.id)
#  reviewer_id  (reviewer_id => users.id)
#

module Cfp
  class ReviewAssignment < ActiveRecord::Base
    belongs_to :proposal, inverse_of: :review_assignments
    belongs_to :reviewer, class_name: 'User'

    validates :reviewer_id, uniqueness: { scope: :proposal_id }

    before_validation { self.assigned_at ||= Time.current }

    scope :active, -> { where(conflict_of_interest: false) }
    scope :without_review, lambda {
      where(<<~SQL.squish)
        NOT EXISTS (
          SELECT 1 FROM cfp_reviews
          WHERE cfp_reviews.proposal_id = cfp_review_assignments.proposal_id
            AND cfp_reviews.reviewer_id = cfp_review_assignments.reviewer_id
        )
      SQL
    }

    def review
      proposal.reviews.find_by reviewer_id: reviewer_id
    end
  end
end
