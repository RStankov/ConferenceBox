# frozen_string_literal: true

class AddOrganizerToSpeakers < ActiveRecord::Migration[5.2]
  def change
    add_column :speakers, :organizer, :boolean, default: false, null: false
  end
end
