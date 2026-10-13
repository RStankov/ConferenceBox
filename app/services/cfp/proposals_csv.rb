# frozen_string_literal: true

require 'csv'

module Cfp
  module ProposalsCsv
    extend self

    HEADERS = [
      'ID',
      'Title',
      'Status',
      'Format',
      'Level',
      'Track',
      'Duration (min)',
      'Speaker',
      'Speaker email',
      'Company',
      'Reviews',
      'Mean score',
      'Median score',
      'Variance',
      'Submitted at',
    ].freeze

    def call(proposals)
      proposals = proposals.includes(:speakers).to_a
      stats = ScoreAggregation.call(proposals)

      CSV.generate do |csv|
        csv << HEADERS
        proposals.each { csv << row(_1, stats.fetch(_1.id)) }
      end
    end

    private

    def row(proposal, stats)
      speaker = proposal.speakers.find(&:primary_contact?) || proposal.speakers.first

      [
        proposal.id,
        proposal.title,
        proposal.status,
        proposal.format,
        proposal.level,
        proposal.track,
        proposal.duration_minutes,
        speaker&.name,
        speaker&.email,
        speaker&.company,
        stats.total,
        stats.mean,
        stats.median,
        stats.variance,
        proposal.submitted_at&.iso8601,
      ]
    end
  end
end
