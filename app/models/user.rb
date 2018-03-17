# frozen_string_literal: true
# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  first_name      :string(255)      not null
#  last_name       :string(255)      not null
#  email           :string(255)      default(""), not null
#  password_digest :string(255)      default(""), not null
#  created_at      :datetime
#  updated_at      :datetime
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
