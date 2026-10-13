# frozen_string_literal: true

module Cfp
  module PromoteToSession
    extend self

    PLACEHOLDER_START_AT = '09:00'
    DEFAULT_DURATION = 30

    def call(proposal)
      raise ArgumentError, 'only accepted proposals can be promoted' unless proposal.accepted? || proposal.confirmed?

      proposal.with_lock do
        return proposal.session if proposal.session

        session = proposal.event.sessions.create!(session_attributes(proposal))
        proposal.speakers.each { session.speakers << find_or_create_speaker(_1) }
        proposal.update! session: session
        session
      end
    end

    private

    def session_attributes(proposal)
      {
        title: proposal.title,
        description: proposal.abstract,
        track: track_number(proposal),
        start_at: PLACEHOLDER_START_AT,
        end_at: end_at(proposal),
      }
    end

    def track_number(proposal)
      tracks = proposal.event.cfp_window&.track_list || []
      index = tracks.index(proposal.track)
      index ? index + 1 : 1
    end

    def end_at(proposal)
      hours, minutes = PLACEHOLDER_START_AT.split(':').map(&:to_i)
      total = (hours * 60) + minutes + (proposal.duration_minutes || DEFAULT_DURATION)
      format '%02d:%02d', total / 60, total % 60
    end

    def find_or_create_speaker(proposal_speaker)
      speaker = Speaker.find_or_initialize_by email: proposal_speaker.email

      if speaker.new_record?
        speaker.name = proposal_speaker.name
        speaker.company = proposal_speaker.company
        speaker.description = proposal_speaker.bio
        speaker.personal_site = proposal_speaker.link_list.first
      end

      speaker.save!
      speaker
    end
  end
end
