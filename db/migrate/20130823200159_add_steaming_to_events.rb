class AddSteamingToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :streaming_code, :text
    add_column :events, :show_streaming, :boolean, :default => false, :null => false
  end
end
