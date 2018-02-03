class AddSocialLinksToConferences < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :facebook_account, :string
    add_column :conferences, :twitter_account, :string
    add_column :conferences, :youtube_account, :string
  end
end
