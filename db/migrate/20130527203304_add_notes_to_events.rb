class AddNotesToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :notes, :text
  end
end
