# frozen_string_literal: true

class CreateSessions < ActiveRecord::Migration[4.2]
  def change
    create_table :sessions do |t|
      t.integer :event_id, null: false
      t.foreign_key :events

      t.integer :speaker_id
      t.foreign_key :speakers

      t.string :start_at, null: false
      t.string :title, null: false
      t.string :slides_url
      t.string :video_url

      t.timestamps null: true
    end
  end
end
