# frozen_string_literal: true

module Cfp
  class ConfirmationsController < ApplicationController
    before_action :require_accepted_proposal

    def new
      @form = ConfirmationForm.new proposal
    end

    def create
      @form = ConfirmationForm.new proposal, confirmation_params

      if @form.save
        redirect_to cfp_submission_path(proposal.token), notice: 'Thanks for confirming! See you at the event'
      else
        render :new
      end
    end

    def decline
      StateMachine.transition proposal, :declined, note: params[:reason].presence || 'Declined by the speaker'
      redirect_to cfp_submission_path(proposal.token), notice: 'Sorry you cannot make it, thanks for letting us know'
    end

    private

    def proposal
      @proposal ||= current_event.cfp_proposals.find_by! token: params[:submission_token]
    end

    def require_accepted_proposal
      return if proposal.accepted?

      redirect_to cfp_submission_path(proposal.token), alert: 'This proposal is not waiting for a confirmation'
    end

    def confirmation_params
      params.fetch(:confirmation, {}).permit(speakers: %i(photo tshirt_size))
    end
  end
end
