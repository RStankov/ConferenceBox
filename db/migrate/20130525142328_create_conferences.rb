class CreateConferences < ActiveRecord::Migration[4.2]
  def change
    create_table :conferences do |t|
      t.string :name
      t.string :contact_name
      t.string :contact_email

      t.timestamps null: true
    end
  end
end
