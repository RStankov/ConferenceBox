# frozen_string_literal: true

class ConnectEventWithSponsors < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :sponsors_announced, :boolean, default: false, null: false

    create_join_table :events, :sponsors do |t|
      t.references :event, index: true, null: false, foreign_key: true
      t.references :sponsor, index: true, null: false, foreign_key: true
      t.index %i(event_id sponsor_id), unique: true
      t.timestamps
    end
  end
end
