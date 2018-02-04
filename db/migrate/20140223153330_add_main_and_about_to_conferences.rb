# frozen_string_literal: true

class AddMainAndAboutToConferences < ActiveRecord::Migration[4.2]
  def change
    change_table :conferences, bulk: true do |t|
      t.boolean :main, default: false, null: false
      t.text :about
      t.index :main
    end
  end
end
