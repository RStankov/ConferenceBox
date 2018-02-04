# frozen_string_literal: true

class AddDomainToConferences < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :domain, :string
  end
end
