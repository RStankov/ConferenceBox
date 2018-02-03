class AddTShirtSizeToSpeakers < ActiveRecord::Migration[4.2]
  def change
    add_column :speakers, :tshirt_size, :string
  end
end
