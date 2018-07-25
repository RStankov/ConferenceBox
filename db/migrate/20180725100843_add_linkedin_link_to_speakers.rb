# frozen_string_literal: true

class AddLinkedinLinkToSpeakers < ActiveRecord::Migration[5.2]
  def change
    add_column :speakers, :linkedin_account, :string
  end
end
