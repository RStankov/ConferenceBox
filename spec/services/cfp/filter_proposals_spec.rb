# frozen_string_literal: true

require 'spec_helper'

describe Cfp::FilterProposals do
  let(:event) { create :event }

  def filter(params = {})
    described_class.call(event.cfp_proposals, params).to_a
  end

  it 'excludes drafts' do
    _draft = create :draft_cfp_proposal, event: event
    submitted = create :cfp_proposal, event: event

    expect(filter).to eq [submitted]
  end

  it 'filters by status, track and format' do
    accepted = create :accepted_cfp_proposal, event: event, track: 'Backend', format: 'talk'
    _other = create :cfp_proposal, event: event, track: 'Frontend', format: 'workshop'

    expect(filter(status: 'accepted')).to eq [accepted]
    expect(filter(track: 'Backend')).to eq [accepted]
    expect(filter(proposal_format: 'talk')).to eq [accepted]
    expect(filter(proposal_format: 'lightning')).to eq []
  end

  it 'ignores blank filters' do
    proposal = create :cfp_proposal, event: event
    expect(filter(status: '', track: '', proposal_format: '')).to eq [proposal]
  end

  it 'filters by score range' do
    low = create :cfp_proposal, event: event
    high = create :cfp_proposal, event: event
    _unreviewed = create :cfp_proposal, event: event
    create :cfp_review, proposal: low, score: 2
    create :cfp_review, proposal: high, score: 5

    expect(filter(min_score: 3)).to eq [high]
    expect(filter(max_score: 3)).to eq [low]
    expect(filter(min_score: 1, max_score: 5)).to contain_exactly low, high
  end

  it 'sorts by newest by default' do
    older = create :cfp_proposal, event: event, submitted_at: 2.days.ago
    newer = create :cfp_proposal, event: event, submitted_at: 1.day.ago

    expect(filter).to eq [newer, older]
    expect(filter(sort: 'unknown')).to eq [newer, older]
  end

  it 'sorts by title' do
    beta = create :cfp_proposal, event: event, title: 'Beta'
    alpha = create :cfp_proposal, event: event, title: 'Alpha'

    expect(filter(sort: 'title')).to eq [alpha, beta]
  end

  it 'sorts by score with unreviewed last' do
    unreviewed = create :cfp_proposal, event: event
    low = create :cfp_proposal, event: event
    high = create :cfp_proposal, event: event
    create :cfp_review, proposal: low, score: 2
    create :cfp_review, proposal: high, score: 4

    expect(filter(sort: 'score')).to eq [high, low, unreviewed]
  end
end
