# frozen_string_literal: true

module Cfp
  module FilterProposals
    extend self

    SORTS = {
      'newest' => Arel.sql('cfp_proposals.submitted_at DESC NULLS LAST, cfp_proposals.id DESC'),
      'title'  => Arel.sql('cfp_proposals.title ASC'),
      'score'  => Arel.sql('average_score DESC NULLS LAST, cfp_proposals.id DESC'),
    }.freeze

    SCORE_SUBQUERY = <<~SQL.squish
      LEFT JOIN (
        SELECT proposal_id, AVG(score) AS average_score
        FROM cfp_reviews
        GROUP BY proposal_id
      ) review_scores ON review_scores.proposal_id = cfp_proposals.id
    SQL

    def call(scope, params)
      scope = scope.submitted.joins(SCORE_SUBQUERY)
      scope = scope.where(status: params[:status]) if params[:status].present?
      scope = scope.where(track: params[:track]) if params[:track].present?
      scope = scope.where(format: params[:proposal_format]) if params[:proposal_format].present?
      scope = scope.where('average_score >= ?', params[:min_score]) if params[:min_score].present?
      scope = scope.where('average_score <= ?', params[:max_score]) if params[:max_score].present?
      scope.order(SORTS.fetch(params[:sort].to_s) { SORTS['newest'] })
    end
  end
end
