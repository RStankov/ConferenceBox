# frozen_string_literal: true

class AddStateToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :state, :string, default: 'future', null: false
  end
end
