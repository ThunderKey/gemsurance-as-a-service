class AddInGemfileToGemUsage < ActiveRecord::Migration[5.0]
  def change
    add_column :gem_usages, :in_gemfile, :boolean, null: false, default: false
  end
end
