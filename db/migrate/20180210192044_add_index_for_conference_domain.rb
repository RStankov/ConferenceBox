# frozen_string_literal: true

class AddIndexForConferenceDomain < ActiveRecord::Migration[5.2]
  def change
    add_index :conferences, :domain
  end
end
