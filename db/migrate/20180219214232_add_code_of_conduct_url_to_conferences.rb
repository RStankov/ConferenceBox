# frozen_string_literal: true

class AddCodeOfConductUrlToConferences < ActiveRecord::Migration[5.2]
  def change
    add_column :conferences, :code_of_conduct_url, :string
  end
end
