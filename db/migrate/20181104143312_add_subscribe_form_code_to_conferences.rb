# frozen_string_literal: true

class AddSubscribeFormCodeToConferences < ActiveRecord::Migration[5.2]
  def change
    add_column :conferences, :subscribe_code, :text
  end
end
