# frozen_string_literal: true

class AddOwnerToResource < ActiveRecord::Migration[5.0]
  def change
    add_reference :resources, :owner

    Resource.where(owner_id: nil).each do |r|
      r.owner = User.first
      r.save!
    end
  end
end
