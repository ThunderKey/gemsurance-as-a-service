class DestroyUnusedGemVersions < ActiveRecord::Migration[5.1]
  def change
    GemVersion.all.each &:destroy_if_not_used
  end
end
