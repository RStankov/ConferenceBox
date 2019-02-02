# frozen_string_literal: true
# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  first_name      :string           not null
#  last_name       :string           not null
#  email           :string           default(""), not null
#  password_digest :string           default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ActiveRecord::Base
  has_secure_password

  validates :password_confirmation, presence: true, if: :password?

  validates :email, uniqueness: true, email: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  def password?
    password.present?
  end
end
