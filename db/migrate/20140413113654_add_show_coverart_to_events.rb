class AddShowCoverartToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :show_coverart, :boolean, null: false, default: false
end
  end
