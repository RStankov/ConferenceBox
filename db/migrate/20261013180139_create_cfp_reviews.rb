# frozen_string_literal: true

class CreateCfpReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :cfp_review_assignments do |t|
      t.references :proposal, null: false, foreign_key: { to_table: :cfp_proposals }
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.datetime :assigned_at, null: false
      t.boolean :conflict_of_interest, null: false, default: false

      t.timestamps
    end

    add_index :cfp_review_assignments, %i(proposal_id reviewer_id), unique: true

    create_table :cfp_reviews do |t|
      t.references :proposal, null: false, foreign_key: { to_table: :cfp_proposals }
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.integer :score, null: false
      t.integer :confidence, null: false
      t.text :comment

      t.timestamps
    end

    add_index :cfp_reviews, %i(proposal_id reviewer_id), unique: true
  end
end
