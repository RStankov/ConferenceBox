# frozen_string_literal: true

class AddInstagramAccountCopywriteAnaliticsCodeToConferences < ActiveRecord::Migration[5.2]
  def change
    add_column :conferences, :instagram_account, :string
    add_column :conferences, :copyright, :string
    add_column :conferences, :analytics_code, :text
  end
end
