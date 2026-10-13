# frozen_string_literal: true

require 'spec_helper'

describe Cfp::ScoreAggregation do
  describe '.call' do
    it 'returns stats keyed by proposal id' do
      reviewed = create :cfp_proposal
      unreviewed = create :cfp_proposal
      create :cfp_review, proposal: reviewed, score: 3
      create :cfp_review, proposal: reviewed, score: 5

      stats = described_class.call [reviewed, unreviewed]

      expect(stats.keys).to eq [reviewed.id, unreviewed.id]
      expect(stats[reviewed.id]).to have_attributes total: 2, mean: 4.0, median: 4.0, variance: 1.0
      expect(stats[unreviewed.id]).to have_attributes total: 0, mean: nil, median: nil, variance: nil
      expect(stats[unreviewed.id]).not_to be_reviewed
    end

    it 'accepts a relation' do
      proposal = create :cfp_proposal
      create :cfp_review, proposal: proposal, score: 2

      stats = described_class.call Cfp::Proposal.all

      expect(stats.fetch(proposal.id).mean).to eq 2.0
    end

    it 'loads scores with a single query' do
      proposals = create_list :cfp_proposal, 3
      proposals.each { create :cfp_review, proposal: _1 }

      queries = []
      subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*, payload|
        queries << payload[:sql] if payload[:sql].include?('cfp_reviews')
      end

      described_class.call proposals

      ActiveSupport::Notifications.unsubscribe subscriber
      expect(queries.size).to eq 1
    end
  end

  describe '.stats' do
    it 'computes the median for odd sample sizes' do
      expect(described_class.stats([5, 1, 3]).median).to eq 3
    end

    it 'computes the median for even sample sizes' do
      expect(described_class.stats([1, 2, 3, 4]).median).to eq 2.5
    end

    it 'rounds mean and variance' do
      stats = described_class.stats [1, 2, 2]

      expect(stats.mean).to eq 1.67
      expect(stats.variance).to eq 0.22
    end

    it 'returns empty stats without scores' do
      expect(described_class.stats([])).to eq described_class::Stats.empty
    end
  end
end
