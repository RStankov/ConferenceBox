# frozen_string_literal: true

# == Schema Information
#
# Table name: cfp_proposal_speakers
#
#  id              :integer          not null, primary key
#  bio             :text
#  company         :string
#  email           :string           not null
#  links           :text
#  name            :string           not null
#  primary_contact :boolean          default(FALSE), not null
#  tshirt_size     :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  proposal_id     :integer          not null
#
# Indexes
#
#  index_cfp_proposal_speakers_on_email                  (email)
#  index_cfp_proposal_speakers_on_proposal_id            (proposal_id)
#  index_cfp_proposal_speakers_on_proposal_id_and_email  (proposal_id,email) UNIQUE
#
# Foreign Keys
#
#  proposal_id  (proposal_id => cfp_proposals.id)
#

module Cfp
  class ProposalSpeaker < ActiveRecord::Base
    TSHIRT_SIZES = %w(XS S M L XL XXL).freeze

    belongs_to :proposal, inverse_of: :speakers

    has_one_attached :photo

    validates :name, presence: true
    validates :email, presence: true, email: true, uniqueness: { scope: :proposal_id, case_sensitive: false }
    validates :tshirt_size, inclusion: { in: TSHIRT_SIZES }, allow_nil: true

    before_validation { self.email = email.to_s.strip.downcase }

    scope :primary, -> { where(primary_contact: true) }

    def link_list
      links.to_s.lines.map(&:strip).compact_blank
    end
  end
end
