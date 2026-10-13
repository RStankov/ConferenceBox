# frozen_string_literal: true

class CreateCfpProposals < ActiveRecord::Migration[8.1]
  def change
    create_table :cfp_proposals do |t|
      t.references :event, null: false, foreign_key: true
      t.references :session, foreign_key: true
      t.string :title
      t.text :abstract
      t.text :outline
      t.string :format
      t.string :level
      t.string :track
      t.integer :duration_minutes
      t.text :notes_for_reviewers
      t.string :status, null: false, default: 'draft'
      t.string :token, null: false
      t.datetime :submitted_at
      t.datetime :decided_at
      t.datetime :decision_sent_at

      t.timestamps
    end

    add_index :cfp_proposals, :token, unique: true
    add_index :cfp_proposals, %i(event_id status)
  end
end
