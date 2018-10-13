# frozen_string_literal: true

class AddCountCaches < ActiveRecord::Migration[5.1]
  def up
    add_column :gem_versions, :vulnerabilities_count, :integer, default: 0
    add_column :resources, :vulnerabilities_count, :integer, default: 0

    [GemVersion, Resource].each do |cls|
      cls.reset_column_information
      cls.all.each do |r|
        cls.update_counters r.id, vulnerabilities_count: r.vulnerabilities.length
      end
    end
  end

  def down
    remove_column :gem_versions, :vulnerabilities_count, :integer, default: 0
    remove_column :resources, :vulnerabilities_count, :integer, default: 0
  end
end
