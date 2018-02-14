# frozen_string_literal: true

class CreateSponsors < ActiveRecord::Migration[5.2]
  def change
    create_table :sponsors do |t|
      t.string :name, null: false
      t.string :website_url, null: false
      t.timestamps null: false
    end
  end
end
