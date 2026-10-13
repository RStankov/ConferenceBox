# frozen_string_literal: true

class CreateCfpWindows < ActiveRecord::Migration[8.1]
  def change
    create_table :cfp_windows do |t|
      t.references :event, null: false, foreign_key: true, index: { unique: true }
      t.datetime :opens_at, null: false
      t.datetime :closes_at, null: false
      t.boolean :blind_review, null: false, default: false
      t.integer :max_submissions_per_speaker, null: false, default: 3
      t.text :guidelines
      t.text :tracks

      t.timestamps
    end
  end
end
