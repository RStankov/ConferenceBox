class AddTrackToSessions < ActiveRecord::Migration[4.2]
  def change
    add_column :sessions, :track, :integer, default: 1, null: false
  end
end
