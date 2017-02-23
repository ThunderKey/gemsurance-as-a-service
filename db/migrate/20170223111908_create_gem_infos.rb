class CreateGemInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :gem_infos do |t|
      t.string :name, null: false
      t.string :source, null: false

      t.timestamps
    end
  end
end
