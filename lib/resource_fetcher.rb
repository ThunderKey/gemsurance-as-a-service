module ResourceFetcher
  @@fetchers = {}

  def self.register key, fetcher
    @@fetchers[key.to_s] = fetcher
  end

  def self.for resource
    self[resource.resource_type].try :new, resource
  end

  def self.[] key
    @@fetchers[key.to_s]
  end

  FileUtils.mkdir_p Rails.application.config.gemfile_dir
end

Dir[File.join Rails.root, 'lib', 'resource_fetcher', '*.rb'].each {|file| require file }
