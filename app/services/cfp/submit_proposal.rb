# frozen_string_literal: true

module Cfp
  module SubmitProposal
    extend self

    def call(proposal)
      StateMachine.transition proposal, :submitted
      ProposalMailer.received(proposal).deliver_later
      proposal
    end
  end
end
