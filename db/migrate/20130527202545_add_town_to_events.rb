class AddTownToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :town, :string
  end
end
