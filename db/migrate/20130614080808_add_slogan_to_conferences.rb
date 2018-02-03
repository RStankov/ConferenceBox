class AddSloganToConferences < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :slogan, :string
  end
end
