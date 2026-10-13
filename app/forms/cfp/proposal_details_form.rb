# frozen_string_literal: true

module Cfp
  class ProposalDetailsForm
    include ActiveModel::Model

    ATTRIBUTES = %i(title abstract outline format level track duration_minutes notes_for_reviewers).freeze
    TITLE_LIMIT = 120
    ABSTRACT_LIMIT = 2000
    DURATION_RANGE = 5..240

    attr_accessor(*ATTRIBUTES)
    attr_reader :proposal

    validates :title, presence: true, length: { maximum: TITLE_LIMIT }
    validates :abstract, presence: true, length: { maximum: ABSTRACT_LIMIT }
    validates :format, inclusion: { in: Proposal::FORMATS.keys }
    validates :level, inclusion: { in: Proposal::LEVELS.keys }
    validates :duration_minutes, numericality: { only_integer: true, in: DURATION_RANGE }
    validate :track_is_offered

    def initialize(proposal, attributes = {})
      @proposal = proposal
      super(proposal.slice(ATTRIBUTES).merge(attributes))
    end

    def save
      return false unless valid?

      proposal.update!(ATTRIBUTES.index_with { public_send _1 })
      true
    end

    def tracks
      proposal.event.cfp_window&.track_list || []
    end

    private

    def track_is_offered
      return if tracks.empty?
      return if tracks.include?(track)

      errors.add :track, 'is not one of the offered tracks'
    end
  end
end
