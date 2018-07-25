# frozen_string_literal: true

# == Schema Information
#
# Table name: sponsors
#
#  id          :bigint(8)        not null, primary key
#  name        :string           not null
#  website_url :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Sponsor < ActiveRecord::Base
  validates :name, presence: true
  validates :website_url, presence: true

  has_and_belongs_to_many :events

  has_one_attached :logo
end
