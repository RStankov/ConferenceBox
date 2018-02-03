class AddMoreSocialLinksToSpeakers < ActiveRecord::Migration[4.2]
  def change
    add_column :speakers, :github_account, :string
    add_column :speakers, :facebook_account, :string
    add_column :speakers, :dribbble_account, :string
  end
end
