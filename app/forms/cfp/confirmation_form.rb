# frozen_string_literal: true

module Cfp
  class ConfirmationForm
    include ActiveModel::Model

    PHOTO_TYPES = %w(image/jpeg image/png image/webp).freeze
    MAX_PHOTO_SIZE = 5.megabytes

    attr_reader :proposal

    validate :proposal_accepted
    validate :speaker_details

    def initialize(proposal, params = {})
      @proposal = proposal
      @params = params.to_h.with_indifferent_access
    end

    def speakers
      proposal.speakers
    end

    def tshirt_size_for(speaker)
      details_for(speaker)[:tshirt_size] || speaker.tshirt_size
    end

    def save
      return false unless valid?

      Proposal.transaction do
        speakers.each { update_speaker _1, details_for(_1) }
        StateMachine.transition proposal, :confirmed, note: 'Confirmed by the speaker'
      end

      true
    end

    private

    def details_for(speaker)
      @params.dig(:speakers, speaker.id.to_s) || {}
    end

    def update_speaker(speaker, details)
      speaker.photo.attach details[:photo] if details[:photo].present?
      speaker.update! tshirt_size: details[:tshirt_size]
    end

    def proposal_accepted
      errors.add :base, 'Only accepted proposals can be confirmed' unless proposal.accepted?
    end

    def speaker_details
      speakers.each do |speaker|
        details = details_for(speaker)
        photo_error = photo_error(speaker, details[:photo])

        errors.add :base, "#{speaker.name}: #{photo_error}" if photo_error
        unless ProposalSpeaker::TSHIRT_SIZES.include?(details[:tshirt_size])
          errors.add :base, "#{speaker.name}: pick a t-shirt size"
        end
      end
    end

    def photo_error(speaker, photo)
      return if photo.blank? && speaker.photo.attached?
      return 'add a photo for the program' if photo.blank?
      return 'the photo must be a JPEG, PNG or WebP image' unless PHOTO_TYPES.include?(photo.content_type)

      'the photo must be smaller than 5 MB' if photo.size > MAX_PHOTO_SIZE
    end
  end
end
