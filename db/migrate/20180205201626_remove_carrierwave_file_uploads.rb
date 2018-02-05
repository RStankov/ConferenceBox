# frozen_string_literal: true

class RemoveCarrierwaveFileUploads < ActiveRecord::Migration[5.2]
  def change
    remove_column :events, :logo
    remove_column :events, :coverart
    remove_column :speakers, :photo
    remove_column :photos, :asset
  end
end
