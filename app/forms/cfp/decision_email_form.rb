# frozen_string_literal: true

module Cfp
  class DecisionEmailForm
    include ActiveModel::Model

    PLACEHOLDERS = %w(speaker_name proposal_title event_name).freeze

    TEMPLATES = {
      'accepted' => {
        subject: 'Your proposal for {{event_name}} has been accepted',
        body: <<~TEXT,
          Hi {{speaker_name}},

          Great news! Your proposal "{{proposal_title}}" has been accepted for {{event_name}}.

          Please confirm you can make it by replying to this email.

          See you there!
        TEXT
      },
      'rejected' => {
        subject: 'Update on your proposal for {{event_name}}',
        body: <<~TEXT,
          Hi {{speaker_name}},

          Thank you for submitting "{{proposal_title}}" to {{event_name}}.

          We received many strong proposals this year and unfortunately we could not fit yours in the program.

          We hope to see a proposal from you next time.
        TEXT
      },
      'waitlisted' => {
        subject: 'Your proposal for {{event_name}} is on the waitlist',
        body: <<~TEXT,
          Hi {{speaker_name}},

          Thank you for submitting "{{proposal_title}}" to {{event_name}}.

          Your proposal is on our waitlist. We will let you know as soon as a slot opens up.
        TEXT
      },
    }.freeze

    attr_accessor :status, :subject, :body

    validates :status, inclusion: { in: TEMPLATES.keys }
    validates :subject, presence: true
    validates :body, presence: true

    def self.default_for(status)
      template = TEMPLATES.fetch(status.to_s) { TEMPLATES['accepted'] }
      new status: status, subject: template[:subject], body: template[:body]
    end

    def render_subject(proposal)
      interpolate subject, proposal
    end

    def render_body(proposal)
      interpolate body, proposal
    end

    def recipients(event)
      event.cfp_proposals.with_status(status).where(decision_sent_at: nil).includes(:speakers)
    end

    private

    def interpolate(text, proposal)
      speaker = proposal.primary_speaker || proposal.speakers.first

      values = {
        'speaker_name'   => speaker&.name,
        'proposal_title' => proposal.title,
        'event_name'     => proposal.event.full_name,
      }

      text.to_s.gsub(/\{\{\s*(\w+)\s*\}\}/) { values.fetch(Regexp.last_match(1), '') }
    end
  end
end
