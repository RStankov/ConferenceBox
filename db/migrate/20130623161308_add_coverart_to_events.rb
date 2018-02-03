class AddCoverartToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :coverart, :string
  end
end
