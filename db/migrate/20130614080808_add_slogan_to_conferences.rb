# frozen_string_literal: true

class AddSloganToConferences < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :slogan, :string
  end
end
