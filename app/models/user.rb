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
#  role            :string           default("admin"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ActiveRecord::Base
  has_secure_password

  enum :role, { admin: 'admin', organizer: 'organizer', reviewer: 'reviewer' }, validate: true

  with_options foreign_key: :reviewer_id, dependent: :destroy, inverse_of: :reviewer do
    has_many :review_assignments, class_name: 'Cfp::ReviewAssignment'
    has_many :reviews, class_name: 'Cfp::Review'
  end

  validates :password_confirmation, presence: true, if: :password?

  validates :email, uniqueness: true, email: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  scope :reviewers, -> { where(role: %w(admin organizer reviewer)) }

  default_scope -> { order 'first_name ASC, last_name ASC' }

  def full_name
    "#{first_name} #{last_name}"
  end

  def organizer_access?
    admin? || organizer?
  end

  def password?
    password.present?
  end
end
