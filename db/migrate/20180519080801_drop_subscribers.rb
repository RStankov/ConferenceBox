# frozen_string_literal: true

class DropSubscribers < ActiveRecord::Migration[5.2]
  def change
    drop_table :subscribers
  end
end
