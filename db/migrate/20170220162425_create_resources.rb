class CreateResources < ActiveRecord::Migration[5.0]
  def change
    create_table :resources do |t|
      t.string :name, null: false
      t.string :path, null: false
      t.string :resource_type, null: false

      t.datetime :fetched_at
      t.string :status, null: false
    end
  end
end
