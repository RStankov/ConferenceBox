# frozen_string_literal: true

class AddSpeakerConfirmationToCfp < ActiveRecord::Migration[8.1]
  def change
    add_column :cfp_proposals, :responded_at, :datetime
    add_column :cfp_proposal_speakers, :tshirt_size, :string
  end
end
