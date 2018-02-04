# frozen_string_literal: true

# == Schema Information
#
# Table name: photos
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  position   :integer          not null
#  asset      :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

class Photo < ActiveRecord::Base
  belongs_to :event

  validates :asset, presence: true
  validates :event, presence: true

  mount_uploader :asset, PhotoAssetUploader

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
    { id: id, asset_url: asset.url(:thumb) }
  end

  private

  def set_position
    self.position = event.photos.maximum('position').to_i + 1 if position.blank?
  end

  def remove_position
    event.photos.where('position > ?', position).update_all 'position = position - 1'
  end
end
