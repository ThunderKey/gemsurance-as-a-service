# frozen_string_literal: true

class AddBuildImageUrlAndBuildUrlToResource < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :build_image_url, :string
    add_column :resources, :build_url, :string
  end
end
