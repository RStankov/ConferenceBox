# frozen_string_literal: true

class CreatePhotos < ActiveRecord::Migration[4.2]
  def change
    create_table :photos do |t|
      t.integer :event_id, null: false
      t.foreign_key :events
      t.integer :position, null: false
      t.string :asset, null: false
      t.timestamps null: true
    end
  end
end
