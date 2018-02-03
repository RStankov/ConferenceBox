class ChangeEventVenueNotesToText < ActiveRecord::Migration[4.2]
  def change
    change_column :events, :venue_notes, :text
  end
end
