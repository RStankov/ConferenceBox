# frozen_string_literal: true

module Cfp
  class SpeakerDetailsForm
    include ActiveModel::Model

    attr_accessor :name, :email, :bio, :company, :links
    attr_reader :proposal

    validates :name, presence: true
    validates :email, presence: true
    validates :email, email: true, allow_blank: true
    validate :submissions_limit

    def initialize(window, attributes = {})
      @window = window
      super(attributes)
    end

    def save
      return false unless valid?

      Proposal.transaction do
        @proposal = @window.event.cfp_proposals.create!
        @proposal.speakers.create!(
          name: name,
          email: email,
          bio: bio,
          company: company,
          links: links,
          primary_contact: true,
        )
      end

      true
    end

    private

    def submissions_limit
      return if email.blank?

      limit = @window.max_submissions_per_speaker
      return if submissions_by_email < limit

      errors.add :email, "has already submitted the maximum of #{limit} proposals"
    end

    def submissions_by_email
      ProposalSpeaker
        .joins(:proposal)
        .where(cfp_proposals: { event_id: @window.event_id })
        .where.not(cfp_proposals: { status: 'withdrawn' })
        .where(email: email.to_s.strip.downcase)
        .count
    end
  end
end
