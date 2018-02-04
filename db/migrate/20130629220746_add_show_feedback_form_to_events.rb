# frozen_string_literal: true

class AddShowFeedbackFormToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :show_feedback_form, :boolean, null: false, default: false
  end
end
