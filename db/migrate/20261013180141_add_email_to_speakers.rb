# frozen_string_literal: true

class AddEmailToSpeakers < ActiveRecord::Migration[8.1]
  def change
    add_column :speakers, :email, :string
    add_index :speakers, :email
  end
end
