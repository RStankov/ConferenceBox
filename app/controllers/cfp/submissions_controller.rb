# frozen_string_literal: true

module Cfp
  class SubmissionsController < ApplicationController
    before_action :require_open_window, except: %i(show)
    before_action :require_editable_proposal, only: %i(edit update submit withdraw)

    def new
      @form = SpeakerDetailsForm.new window
    end

    def create
      @form = SpeakerDetailsForm.new window, speaker_params

      if @form.save
        redirect_to edit_cfp_submission_path(@form.proposal.token)
      else
        render :new
      end
    end

    def show
      @proposal = ProposalDecorator.decorate find_proposal
      @window = window
    end

    def edit
      @proposal = find_proposal
      @form = ProposalDetailsForm.new @proposal
    end

    def update
      @proposal = find_proposal
      @form = ProposalDetailsForm.new @proposal, proposal_params

      if @form.save
        redirect_to cfp_submission_path(@proposal.token), notice: 'Your proposal is saved'
      else
        render :edit
      end
    end

    def submit
      proposal = find_proposal

      if proposal.draft? && ProposalDetailsForm.new(proposal).valid?
        SubmitProposal.call proposal
        redirect_to cfp_submission_path(proposal.token), notice: 'Thanks! Your proposal is submitted'
      else
        redirect_to edit_cfp_submission_path(proposal.token), alert: 'Please complete your proposal before submitting'
      end
    end

    def withdraw
      proposal = find_proposal
      StateMachine.transition proposal, :withdrawn, note: 'Withdrawn by the submitter'
      redirect_to cfp_submission_path(proposal.token), notice: 'Your proposal is withdrawn'
    end

    private

    def window
      current_event.cfp_window
    end

    def require_open_window
      return if window&.open?

      redirect_to cfp_path, alert: 'The call for papers is not open'
    end

    def require_editable_proposal
      return if find_proposal.editable_by_submitter?

      redirect_to cfp_submission_path(params[:token]), alert: 'This proposal can no longer be changed'
    end

    def find_proposal
      @find_proposal ||= current_event.cfp_proposals.find_by! token: params[:token]
    end

    def speaker_params
      params.require(:speaker).permit(:name, :email, :bio, :company, :links)
    end

    def proposal_params
      params.require(:proposal).permit(*ProposalDetailsForm::ATTRIBUTES)
    end
  end
end
