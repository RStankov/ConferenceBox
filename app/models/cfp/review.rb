# frozen_string_literal: true

# == Schema Information
#
# Table name: cfp_reviews
#
#  id          :integer          not null, primary key
#  comment     :text
#  confidence  :integer          not null
#  score       :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  proposal_id :integer          not null
#  reviewer_id :integer          not null
#
# Indexes
#
#  index_cfp_reviews_on_proposal_id                  (proposal_id)
#  index_cfp_reviews_on_proposal_id_and_reviewer_id  (proposal_id,reviewer_id) UNIQUE
#  index_cfp_reviews_on_reviewer_id                  (reviewer_id)
#
# Foreign Keys
#
#  proposal_id  (proposal_id => cfp_proposals.id)
#  reviewer_id  (reviewer_id => users.id)
#

module Cfp
  class Review < ActiveRecord::Base
    SCORES = {
      1 => 'Strong reject',
      2 => 'Reject',
      3 => 'Neutral',
      4 => 'Accept',
      5 => 'Strong accept',
    }.freeze

    CONFIDENCES = {
      1 => 'Low, outside my expertise',
      2 => 'Medium',
      3 => 'High, this is my field',
    }.freeze

    belongs_to :proposal, inverse_of: :reviews
    belongs_to :reviewer, class_name: 'User'

    validates :score, inclusion: { in: SCORES.keys }
    validates :confidence, inclusion: { in: CONFIDENCES.keys }
    validates :reviewer_id, uniqueness: { scope: :proposal_id }

    scope :newest, -> { order('id DESC') }

    def score_label
      SCORES[score]
    end

    def confidence_label
      CONFIDENCES[confidence]
    end
  end
end
