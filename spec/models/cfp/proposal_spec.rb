# frozen_string_literal: true

require 'spec_helper'

describe Cfp::Proposal do
  describe 'status predicates' do
    it 'defines a predicate per status' do
      described_class::STATUSES.each do |status|
        proposal = build :cfp_proposal, status: status
        expect(proposal.public_send(:"#{status}?")).to be true
      end
    end

    it 'is decided only for accepted, rejected and waitlisted' do
      expect(build(:cfp_proposal, status: 'accepted')).to be_decided
      expect(build(:cfp_proposal, status: 'rejected')).to be_decided
      expect(build(:cfp_proposal, status: 'waitlisted')).to be_decided
      expect(build(:cfp_proposal, status: 'under_review')).not_to be_decided
    end

    it 'is reviewable for submitted and under review' do
      expect(build(:cfp_proposal, status: 'submitted')).to be_reviewable
      expect(build(:cfp_proposal, status: 'under_review')).to be_reviewable
      expect(build(:cfp_proposal, status: 'accepted')).not_to be_reviewable
    end

    it 'is editable by the submitter while draft or submitted' do
      expect(build(:draft_cfp_proposal)).to be_editable_by_submitter
      expect(build(:cfp_proposal, status: 'submitted')).to be_editable_by_submitter
      expect(build(:cfp_proposal, status: 'under_review')).not_to be_editable_by_submitter
    end

    it 'is promotable when accepted or confirmed and not yet in the schedule' do
      expect(build(:accepted_cfp_proposal)).to be_promotable
      expect(build(:cfp_proposal, status: 'confirmed')).to be_promotable
      expect(build(:cfp_proposal, status: 'rejected')).not_to be_promotable
      expect(build(:accepted_cfp_proposal, session: create(:session))).not_to be_promotable
    end

    it 'is promoted once linked to a session' do
      expect(build(:accepted_cfp_proposal, session: create(:session))).to be_promoted
      expect(build(:accepted_cfp_proposal)).not_to be_promoted
    end
  end

  describe 'validations' do
    it 'allows an empty draft' do
      expect(build(:draft_cfp_proposal)).to be_valid
    end

    it 'requires title, abstract and format once submitted' do
      proposal = build :cfp_proposal, title: nil, abstract: nil, format: nil

      expect(proposal).to have_error_on :title
      expect(proposal).to have_error_on :abstract
      expect(proposal).to have_error_on :format
    end

    it 'rejects unknown format and level' do
      proposal = build :cfp_proposal, format: 'keynote', level: 'guru'

      expect(proposal).to have_error_on :format
      expect(proposal).to have_error_on :level
    end

    it 'rejects unknown status' do
      expect(build(:cfp_proposal, status: 'lost')).to have_error_on :status
    end

    it 'generates a token' do
      expect(create(:cfp_proposal).token).to be_present
    end
  end

  describe 'scopes' do
    it '.with_status filters by status' do
      accepted = create :accepted_cfp_proposal
      _submitted = create :cfp_proposal

      expect(described_class.with_status('accepted')).to eq [accepted]
    end

    it '.submitted excludes drafts' do
      _draft = create :draft_cfp_proposal
      submitted = create :cfp_proposal

      expect(described_class.submitted).to eq [submitted]
    end

    it '.reviewable includes submitted and under review' do
      submitted = create :cfp_proposal, status: 'submitted'
      under_review = create :cfp_proposal, status: 'under_review'
      _accepted = create :accepted_cfp_proposal

      expect(described_class.reviewable).to contain_exactly submitted, under_review
    end

    it '.accepted includes accepted and confirmed' do
      accepted = create :accepted_cfp_proposal
      confirmed = create :cfp_proposal, status: 'confirmed'
      _rejected = create :cfp_proposal, status: 'rejected'

      expect(described_class.accepted).to contain_exactly accepted, confirmed
    end

    it '.newest orders by submission time with drafts last' do
      older = create :cfp_proposal, submitted_at: 2.days.ago
      draft = create :draft_cfp_proposal
      newer = create :cfp_proposal, submitted_at: 1.day.ago

      expect(described_class.newest).to eq [newer, older, draft]
    end
  end

  describe '#speaker_emails' do
    it 'returns lower cased speaker emails' do
      proposal = create :cfp_proposal, speaker_email: 'jane@example.org'
      proposal.speakers.create! name: 'Co', email: 'co@example.org'

      expect(proposal.speaker_emails).to contain_exactly 'jane@example.org', 'co@example.org'
    end
  end
end
