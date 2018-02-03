class AddTwitterToSpeakers < ActiveRecord::Migration[4.2]
  def change
    add_column :speakers, :twitter_account, :string
  end
end
