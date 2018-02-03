class AddShowPhotoGalleryToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :show_photo_gallery, :boolean, default: false, null: false
  end
end
