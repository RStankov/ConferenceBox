class DropSubscribers < ActiveRecord::Migration[5.2]
  def change
    drop_table :subscribers
  end
end
