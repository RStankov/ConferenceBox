# frozen_string_literal: true

class CreateCfpDiscussion < ActiveRecord::Migration[8.1]
  def change
    create_table :cfp_comments do |t|
      t.references :proposal, null: false, foreign_key: { to_table: :cfp_proposals }
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end

    create_table :cfp_status_changes do |t|
      t.references :proposal, null: false, foreign_key: { to_table: :cfp_proposals }
      t.references :user, foreign_key: true
      t.string :from_status
      t.string :to_status, null: false
      t.text :note

      t.timestamps
    end
  end
end
