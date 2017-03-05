class CreateVulnerabilities < ActiveRecord::Migration[5.0]
  def change
    create_table :vulnerabilities do |t|
      t.string :description, null: false
      t.string :cve
      t.string :url
      t.string :patched_versions
      t.references :gem_version, foreign_key: true, index: true

      t.timestamps
    end
  end
end
