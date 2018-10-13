# frozen_string_literal: true

class AddFetchOutputToResources < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :fetch_output, :text, null: false
  end
end
