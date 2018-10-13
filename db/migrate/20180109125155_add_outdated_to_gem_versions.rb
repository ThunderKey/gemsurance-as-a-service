# frozen_string_literal: true

class AddOutdatedToGemVersions < ActiveRecord::Migration[5.1]
  def change
    add_column :gem_versions, :outdated, :boolean

    GemInfo.all.each(&:update_all_gem_versions!)
  end
end
