class CreateSubscribers < ActiveRecord::Migration[4.2]
  def change
    create_table :subscribers do |t|
      t.references :conference
      t.foreign_key :conferences

      t.string :email, null: false
      t.boolean :active, null: false, default: true

      t.timestamps null: true
    end
  end
end
