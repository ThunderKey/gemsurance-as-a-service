class UpdateResourceJob < ApplicationJob
  queue_as :default

  def perform(resource_id)
    resource = Resource.find(resource_id)
    resource.update_gems!
  end
end
