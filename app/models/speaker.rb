# frozen_string_literal: true

# == Schema Information
#
# Table name: speakers
#
#  id                :integer          not null, primary key
#  name              :string           not null
#  description       :text
#  personal_site     :string
#  company           :string
#  company_site      :string
#  created_at        :datetime
#  updated_at        :datetime
#  twitter_account   :string
#  tshirt_size       :string
#  github_account    :string
#  facebook_account  :string
#  dribbble_account  :string
#  organizer         :boolean          default(FALSE), not null
#  instagram_account :string
#  linkedin_account  :string
#

class Speaker < ActiveRecord::Base
  has_many :session_speakers, dependent: :destroy
  has_many :sessions, through: :session_speakers

  validates :name, presence: true

  has_one_attached :photo

  scope :organizers, -> { where(organizer: true) }

  default_scope -> { order 'name ASC' }

  def sessions_count
    sessions.count
  end
end
