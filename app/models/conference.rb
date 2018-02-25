# frozen_string_literal: true

# == Schema Information
#
# Table name: conferences
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  contact_name        :string(255)
#  contact_email       :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  facebook_account    :string(255)
#  twitter_account     :string(255)
#  youtube_account     :string(255)
#  domain              :string(255)
#  slogan              :string(255)
#  main                :boolean          default(FALSE), not null
#  about               :text
#  theme               :string           default("default"), not null
#  instagram_account   :string
#  copyright           :string
#  analytics_code      :text
#  code_of_conduct_url :string
#

class Conference < ActiveRecord::Base
  THEMES = %w(it_tour not_a_conf).freeze

  validates :name, presence: true
  validates :domain, presence: true, uniqueness: true
  validates :theme, presence: true, inclusion: { in: THEMES }

  has_many :events, dependent: :destroy
  has_many :subscribers, dependent: :nullify

  after_save :ensure_only_one_main, if: :main?

  class << self
    def find_for_domain(domain)
      where(domain: domain).first!
    end

    def regular
      where(main: false)
    end

    def with_events
      includes(:events).where('events.publicly_announced' => true)
    end
  end

  def current_event
    @current_event = events.publicly_announced.reorder('current DESC').first!
  end

  def announced_event_named(name)
    events.publicly_announced.find_by! name: name
  end

  def regular?
    !main?
  end

  private

  def ensure_only_one_main
    self.class.where('id != ? AND main', id).update_all main: false
  end
end
