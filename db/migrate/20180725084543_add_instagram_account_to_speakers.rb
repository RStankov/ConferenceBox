# frozen_string_literal: true

class AddInstagramAccountToSpeakers < ActiveRecord::Migration[5.2]
  def change
    add_column :speakers, :instagram_account, :string
  end
end
