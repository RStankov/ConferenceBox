class AddLogoToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :logo, :string
  end
end
