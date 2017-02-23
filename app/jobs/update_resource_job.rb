class UpdateResourceJob < ApplicationJob
  queue_as :default

  def perform(resource_id)
    resource = Resource.find(resource_id)
    fetcher = resource.resource_fetcher
    raise "unknown fetcher for #{resource.inspect}" unless fetcher
    fetcher.update_files
    puts fetcher.gems
  end
end
