# frozen_string_literal: true

module Cfp
  module ScoreAggregation
    extend self

    Stats = Struct.new(:total, :mean, :median, :variance) do
      def self.empty
        new 0, nil, nil, nil
      end

      def reviewed?
        total.positive?
      end
    end

    def call(proposals)
      ids = proposals.map(&:id)
      scores = Review.where(proposal_id: ids).pluck(:proposal_id, :score).group_by(&:first)

      ids.index_with { |id| stats(scores.fetch(id, []).map(&:last)) }
    end

    def stats(scores)
      return Stats.empty if scores.empty?

      mean = scores.sum.fdiv(scores.size)
      variance = scores.sum { (_1 - mean)**2 }.fdiv(scores.size)

      Stats.new scores.size, mean.round(2), median(scores), variance.round(2)
    end

    private

    def median(scores)
      sorted = scores.sort
      middle = sorted.size / 2

      if sorted.size.odd?
        sorted[middle]
      else
        (sorted[middle - 1] + sorted[middle]).fdiv(2)
      end
    end
  end
end
