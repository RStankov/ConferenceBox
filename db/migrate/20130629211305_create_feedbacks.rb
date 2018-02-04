# frozen_string_literal: true

class CreateFeedbacks < ActiveRecord::Migration[4.2]
  def change
    create_table :feedbacks do |t|
      t.integer :event_id, null: false
      t.foreign_key :events
      t.text :comment, null: false
      t.timestamps null: true
    end
  end
end
