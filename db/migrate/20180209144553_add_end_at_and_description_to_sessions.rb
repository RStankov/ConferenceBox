# frozen_string_literal: true

class AddEndAtAndDescriptionToSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :sessions, :end_at, :string
    add_column :sessions, :description, :text
  end
end
