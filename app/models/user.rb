# frozen_string_literal: true

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
