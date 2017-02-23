class CreateGemVersions < ActiveRecord::Migration[5.0]
  def change
    create_table :gem_versions do |t|
      t.references :gem_info, foreign_key: true, index: true, null: false
      t.string :version, null: false

      t.timestamps
    end
  end
end
