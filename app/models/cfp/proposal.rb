# frozen_string_literal: true

# == Schema Information
#
# Table name: cfp_proposals
#
#  id                  :integer          not null, primary key
#  abstract            :text
#  decided_at          :datetime
#  decision_sent_at    :datetime
#  duration_minutes    :integer
#  format              :string
#  level               :string
#  notes_for_reviewers :text
#  outline             :text
#  status              :string           default("draft"), not null
#  submitted_at        :datetime
#  title               :string
#  token               :string           not null
#  track               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  event_id            :integer          not null
#  session_id          :integer
#
# Indexes
#
#  index_cfp_proposals_on_event_id             (event_id)
#  index_cfp_proposals_on_event_id_and_status  (event_id,status)
#  index_cfp_proposals_on_session_id           (session_id)
#  index_cfp_proposals_on_token                (token) UNIQUE
#
# Foreign Keys
#
#  event_id    (event_id => events.id)
#  session_id  (session_id => sessions.id)
#

module Cfp
  class Proposal < ActiveRecord::Base
    STATUSES = %w(draft submitted under_review accepted rejected waitlisted confirmed declined withdrawn).freeze
    REVIEWABLE_STATUSES = %w(submitted under_review).freeze
    DECIDED_STATUSES = %w(accepted rejected waitlisted).freeze
    SUBMITTER_EDITABLE_STATUSES = %w(draft submitted).freeze

    FORMATS = { 'talk' => 'Talk', 'workshop' => 'Workshop', 'lightning' => 'Lightning talk' }.freeze
    LEVELS = { 'beginner' => 'Beginner', 'intermediate' => 'Intermediate', 'advanced' => 'Advanced' }.freeze

    belongs_to :event
    belongs_to :session, optional: true

    has_many :speakers, class_name: 'Cfp::ProposalSpeaker', dependent: :destroy, inverse_of: :proposal
    has_one :primary_speaker, -> { where(primary_contact: true) }, class_name: 'Cfp::ProposalSpeaker', inverse_of: :proposal
    has_many :reviews, dependent: :destroy, inverse_of: :proposal
    has_many :review_assignments, dependent: :destroy, inverse_of: :proposal
    has_many :reviewers, through: :review_assignments
    has_many :comments, dependent: :destroy, inverse_of: :proposal
    has_many :status_changes, dependent: :destroy, inverse_of: :proposal

    has_secure_token

    validates :status, inclusion: { in: STATUSES }
    validates :format, inclusion: { in: FORMATS.keys }, allow_nil: true
    validates :level, inclusion: { in: LEVELS.keys }, allow_nil: true
    validates :title, :abstract, :format, presence: true, if: :submitted_at?

    attr_readonly :event_id

    scope :with_status, ->(status) { where(status: status) }
    scope :submitted, -> { where.not(status: 'draft') }
    scope :reviewable, -> { where(status: REVIEWABLE_STATUSES) }
    scope :accepted, -> { where(status: %w(accepted confirmed)) }
    scope :newest, -> { order(Arel.sql('submitted_at DESC NULLS LAST, id DESC')) }

    STATUSES.each do |value|
      define_method(:"#{value}?") { status == value }
    end

    def decided?
      DECIDED_STATUSES.include? status
    end

    def reviewable?
      REVIEWABLE_STATUSES.include? status
    end

    def editable_by_submitter?
      SUBMITTER_EDITABLE_STATUSES.include? status
    end

    def promotable?
      (accepted? || confirmed?) && session_id.nil?
    end

    def promoted?
      session_id.present?
    end

    def speaker_emails
      speakers.map { _1.email.downcase }
    end
  end
end
