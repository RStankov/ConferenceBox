class AddColorToConferences < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :color, :string
  end
end
