class AddPhotoToSpeakers < ActiveRecord::Migration[4.2]
  def change
    add_column :speakers, :photo, :string
  end
end
