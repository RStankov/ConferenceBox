# frozen_string_literal: true

# == Schema Information
#
# Table name: feedbacks
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  comment    :text             not null
#  created_at :datetime
#  updated_at :datetime
#

class Feedback < ActiveRecord::Base
  belongs_to :event

  validates :comment, presence: true
  validates :event, presence: true

  default_scope -> { order('id DESC') }

  def event_name
    event.full_name
  end
end
