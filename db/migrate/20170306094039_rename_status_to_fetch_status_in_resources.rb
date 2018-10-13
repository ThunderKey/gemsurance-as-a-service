# frozen_string_literal: true

class RenameStatusToFetchStatusInResources < ActiveRecord::Migration[5.0]
  def change
    rename_column :resources, :status, :fetch_status
  end
end
