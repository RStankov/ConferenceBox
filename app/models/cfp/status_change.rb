# frozen_string_literal: true

# == Schema Information
#
# Table name: cfp_status_changes
#
#  id          :integer          not null, primary key
#  from_status :string
#  note        :text
#  to_status   :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  proposal_id :integer          not null
#  user_id     :integer
#
# Indexes
#
#  index_cfp_status_changes_on_proposal_id  (proposal_id)
#  index_cfp_status_changes_on_user_id      (user_id)
#
# Foreign Keys
#
#  proposal_id  (proposal_id => cfp_proposals.id)
#  user_id      (user_id => users.id)
#

module Cfp
  class StatusChange < ActiveRecord::Base
    belongs_to :proposal, inverse_of: :status_changes
    belongs_to :user, optional: true

    validates :to_status, inclusion: { in: Proposal::STATUSES }

    scope :oldest, -> { order('id ASC') }

    def actor_name
      user ? user.full_name : 'Submitter'
    end
  end
end
