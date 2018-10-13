# frozen_string_literal: true

class UpdateGemColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :gem_infos, :source
    add_column :gem_infos, :homepage_url, :string
    add_column :gem_infos, :source_code_url, :string
    add_column :gem_infos, :documentation_url, :string
  end
end
