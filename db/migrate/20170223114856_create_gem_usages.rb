class CreateGemUsages < ActiveRecord::Migration[5.0]
  def change
    create_table :gem_usages do |t|
      t.references :gem_version, foreign_key: true, index: true, null: false
      t.references :resource, foreign_key: true, index: true, null: false

      t.timestamps
    end
  end
end
