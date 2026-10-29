# frozen_string_literal: true

module Cfp
  class WindowDecorator < Draper::Decorator
    decorates 'Cfp::Window'
    delegate_all

    STATUS_BADGES = { upcoming: :secondary, open: :success, closed: :danger }.freeze

    def status_label
      status.to_s.humanize
    end

    def status_badge_type
      STATUS_BADGES.fetch status
    end

    def formatted_opens_at
      h.l opens_at, format: :long
    end

    def formatted_closes_at
      h.l closes_at, format: :long
    end

    def deadline_sentence
      case status
      in :upcoming then "Opens #{formatted_opens_at}"
      in :open then "Closes #{formatted_closes_at}, #{h.distance_of_time_in_words_to_now closes_at} from now"
      in :closed then "Closed #{formatted_closes_at}"
      end
    end

    def guidelines_html
      h.markdown guidelines
    end

    def status_counts
      event.cfp_proposals.submitted.group(:status).count.sort_by { Proposal::STATUSES.index(_1.first) }
    end
  end
end
