# frozen_string_literal: true

# == Schema Information
#
# Table name: speakers
#
#  id               :integer          not null, primary key
#  name             :string(255)      not null
#  description      :text
#  personal_site    :string(255)
#  company          :string(255)
#  company_site     :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  twitter_account  :string(255)
#  tshirt_size      :string(255)
#  github_account   :string(255)
#  facebook_account :string(255)
#  dribbble_account :string(255)
#

class Speaker < ActiveRecord::Base
  has_many :session_speakers, dependent: :destroy
  has_many :sessions, through: :session_speakers

  validates :name, presence: true

  has_one_attached :photo

  default_scope -> { order 'name ASC' }

  def sessions_count
    sessions.count
  end
end
