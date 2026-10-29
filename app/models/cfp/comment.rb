# frozen_string_literal: true

# == Schema Information
#
# Table name: cfp_comments
#
#  id          :integer          not null, primary key
#  body        :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  proposal_id :integer          not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_cfp_comments_on_proposal_id  (proposal_id)
#  index_cfp_comments_on_user_id      (user_id)
#
# Foreign Keys
#
#  proposal_id  (proposal_id => cfp_proposals.id)
#  user_id      (user_id => users.id)
#

module Cfp
  class Comment < ActiveRecord::Base
    belongs_to :proposal, inverse_of: :comments
    belongs_to :user

    validates :body, presence: true

    scope :oldest, -> { order('id ASC') }
  end
end
