# frozen_string_literal: true

class UpdateResourceJob < ApplicationJob
  queue_as :default

  def perform(resource_id)
    service = GemsuranceService.new Resource.find(resource_id)
    service.update_gems
  end
end
