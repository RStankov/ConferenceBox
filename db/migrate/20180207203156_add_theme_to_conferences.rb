class AddThemeToConferences < ActiveRecord::Migration[5.2]
  def change
    add_column :conferences, :theme, :string, default: 'default', null: false
  end
end
