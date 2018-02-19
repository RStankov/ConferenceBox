# frozen_string_literal: true

class AddBuyTicketsUrlToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :tickets_url, :string
  end
end
