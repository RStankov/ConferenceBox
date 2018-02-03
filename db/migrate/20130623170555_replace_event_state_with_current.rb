class ReplaceEventStateWithCurrent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :current, :boolean, default: false, null: false
    execute "UPDATE events SET current='t' WHERE state='current'"
    remove_column :events, :state
  end
end
