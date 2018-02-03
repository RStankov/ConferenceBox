class AddCallToPapersLinkToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :call_to_papers_url, :string
  end
end
