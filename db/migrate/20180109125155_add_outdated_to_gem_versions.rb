class AddOutdatedToGemVersions < ActiveRecord::Migration[5.1]
  def change
    add_column :gem_versions, :outdated, :boolean

    GemInfo.all.each do |i|
      i.update_all_gem_versions!
    end
  end
end
