# frozen_string_literal: true

require 'spec_helper'

describe Cfp::Review do
  it 'requires score between 1 and 5' do
    expect(build(:cfp_review, score: 0)).to have_error_on :score
    expect(build(:cfp_review, score: 6)).to have_error_on :score
    expect(build(:cfp_review, score: 5)).to be_valid
  end

  it 'requires confidence between 1 and 3' do
    expect(build(:cfp_review, confidence: 0)).to have_error_on :confidence
    expect(build(:cfp_review, confidence: 4)).to have_error_on :confidence
    expect(build(:cfp_review, confidence: 3)).to be_valid
  end

  it 'allows one review per reviewer per proposal' do
    existing = create :cfp_review
    duplicate = build :cfp_review, proposal: existing.proposal, reviewer: existing.reviewer
    other_proposal = build :cfp_review, reviewer: existing.reviewer

    expect(duplicate).to have_error_on :reviewer_id
    expect(other_proposal).to be_valid
  end

  it 'has human labels for score and confidence' do
    review = build :cfp_review, score: 5, confidence: 1

    expect(review.score_label).to eq 'Strong accept'
    expect(review.confidence_label).to eq 'Low, outside my expertise'
  end

  describe '.newest' do
    it 'orders by id descending' do
      first = create :cfp_review
      second = create :cfp_review

      expect(described_class.newest).to eq [second, first]
    end
  end
end
