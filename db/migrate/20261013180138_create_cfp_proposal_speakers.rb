# frozen_string_literal: true

class CreateCfpProposalSpeakers < ActiveRecord::Migration[8.1]
  def change
    create_table :cfp_proposal_speakers do |t|
      t.references :proposal, null: false, foreign_key: { to_table: :cfp_proposals }
      t.string :name, null: false
      t.string :email, null: false
      t.text :bio
      t.string :company
      t.text :links
      t.boolean :primary_contact, null: false, default: false

      t.timestamps
    end

    add_index :cfp_proposal_speakers, %i(proposal_id email), unique: true
    add_index :cfp_proposal_speakers, :email
  end
end
