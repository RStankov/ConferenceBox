# frozen_string_literal: true

module Cfp
  class CloseWindowsJob < ApplicationJob
    queue_as :default

    def perform
      Window.where(closes_at: ...Time.current).find_each { close _1 }
    end

    private

    def close(window)
      proposals = window.event.cfp_proposals

      proposals.with_status('draft').find_each do |proposal|
        StateMachine.transition proposal, :withdrawn, note: 'Call for papers closed before the proposal was submitted'
      end

      proposals.with_status('submitted').find_each do |proposal|
        StateMachine.transition proposal, :under_review, note: 'Call for papers closed'
      end
    end
  end
end
