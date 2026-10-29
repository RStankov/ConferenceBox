# frozen_string_literal: true

module Cfp
  class ProposalDecorator < Draper::Decorator
    decorates 'Cfp::Proposal'
    delegate_all

    STATUS_BADGES = {
      'draft'        => :light,
      'submitted'    => :info,
      'under_review' => :primary,
      'accepted'     => :success,
      'rejected'     => :danger,
      'waitlisted'   => :warning,
      'confirmed'    => :success,
      'declined'     => :secondary,
      'withdrawn'    => :secondary,
    }.freeze

    HIDDEN_SPEAKER = 'Hidden (blind review)'

    def blind?
      context[:blind] == true
    end

    def status_label
      status.humanize
    end

    def status_badge_type
      STATUS_BADGES.fetch status
    end

    def format_label
      Proposal::FORMATS[object.format]
    end

    def level_label
      Proposal::LEVELS[level]
    end

    def duration_label
      "#{duration_minutes} min" if duration_minutes
    end

    def speaker_names
      return HIDDEN_SPEAKER if blind?

      speakers.map(&:name).join(', ')
    end

    def primary_speaker_email
      return HIDDEN_SPEAKER if blind?

      (primary_speaker || speakers.first)&.email
    end

    def visible_speakers
      blind? ? [] : speakers
    end

    def average_score
      object.reviews.average(:score)&.round(2)
    end

    def reviews_count
      object.reviews.count
    end

    def submitted_on
      h.l submitted_at, format: :long if submitted_at
    end

    def responded_on
      h.l responded_at, format: :long if responded_at
    end

    def abstract_html
      h.markdown abstract
    end

    def outline_html
      h.markdown outline
    end

    def allowed_decisions
      StateMachine.allowed_transitions(object) & DecideProposals::DECISIONS.keys
    end
  end
end
