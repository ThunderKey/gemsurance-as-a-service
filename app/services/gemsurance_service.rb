class GemsuranceService
  @@fetchers = {
    'local' => LocalFetcher,
  }

  def self.fetchers() @@fetchers; end

  attr_reader :resource, :fetcher

  def initialize resource
    @resource = resource
    @fetcher = self.class.fetchers[resource.resource_type] || raise("Unknown Fetcher for #{resource.resource_type}")
  end

  def dirname
    @dirname ||= begin
      resource_id = @resource.id.to_s
      raise "id of the resource is empty: #{@resource.inspect}" if resource_id.blank?
      File.join Rails.application.config.private_dir, 'gemsurance_reports', resource_id
    end
  end

  def gemsurance_yaml_file
    @gemsurance_yaml_file ||= File.join dirname, 'gemsurance_report.yml'
  end

  def update_gemsurance_report
    FileUtils.mkdir_p dirname unless File.exists? dirname
    fetcher.update_gemsurance_report resource, gemsurance_yaml_file
    reset!
  end

  def errors
    fetcher.errors(resource)
  end

  def reset!
    @gems = nil
  end

  def gems
    @gems ||= YAML.load_file gemsurance_yaml_file
  end

  def update_gems
    update_gemsurance_report
    load_gems
  end

  def load_gems
    ids_to_keep = []
    gems.each do |name, gem_data|
      info = GemInfo.where(name: name).first_or_initialize
      info.homepage_url = gem_data['homepage_url']
      info.source_code_url = gem_data['source_code_url']
      info.documentation_url = gem_data['documentation_url']
      info.save!
      GemVersion.where(gem_info: info, version: gem_data['newest_version']).first_or_create! if gem_data['newset_version'] != gem_data['bundle_version']
      version = GemVersion.where(gem_info: info, version: gem_data['bundle_version']).first_or_create!
      usage = resource.gem_usages.where(gem_version: version, in_gemfile: gem_data['in_gem_file']).first_or_create!
      ids_to_keep << usage.id
    end
    resource.gem_usages.where.not(id: ids_to_keep).destroy_all
    resource.gem_usages.reload # because it's destroyed in a seperate ActiveRecord::Relation
  end
end
