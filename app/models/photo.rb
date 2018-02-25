# frozen_string_literal: true

# == Schema Information
#
# Table name: photos
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  position   :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class Photo < ActiveRecord::Base
  belongs_to :event, inverse_of: :photos

  has_one_attached :asset

  before_create :set_position
  after_destroy :remove_position

  scope :ordered, -> { order 'position DESC' }

  class << self
    def change_position_of(ids, scope = {})
      position = where(id: ids).minimum('position').to_i
      Array(ids).reverse.each_with_index do |id, i|
        where(scope.merge(id: id)).update_all position: position + i
      end
    end
  end

  def as_json(_options = {})
    url = asset.variant(resize: '250x250^', gravity: 'center', crop: '250x250+0+0').processed.service_url if asset.attached?

    {
      id: id,
      asset_url: url,
    }
  end

  private

  def set_position
    self.position = event.photos.maximum('position').to_i + 1 if position.blank?
  end

  def remove_position
    event.photos.where('position > ?', position).update_all 'position = position - 1'
  end
end
