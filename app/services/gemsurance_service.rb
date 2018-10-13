# frozen_string_literal: true

class GemsuranceService < ApplicationService
  class_variable_set '@@fetchers', 'local' => LocalFetcher
  cattr_reader :fetchers

  attr_reader :resource, :fetcher

  def initialize resource
    @resource = resource
    @fetcher = self.class.fetchers[resource.resource_type] ||
               raise("Unknown Fetcher for #{resource.resource_type}")
  end

  def dirname
    @dirname ||= begin
      resource_id = @resource.id.to_s
      raise "id of the resource is empty: #{@resource.inspect}" if resource_id.blank?

      Rails.application.config.private_dir.join 'gemsurance_reports', resource_id
    end
  end

  def gemsurance_yaml_file
    @gemsurance_yaml_file ||= dirname.join 'gemsurance_report.yml'
  end

  def update_gemsurance_report
    FileUtils.mkdir_p dirname unless File.exist? dirname
    output, _exit_status = fetcher.update_gemsurance_report resource, gemsurance_yaml_file
    resource.fetch_output = output
    resource.fetched_at = DateTime.now
    resource.fetch_status = gemsurance_regex.match?(output) ? 'successful' : 'failed'
    resource.save!
    reset!
    resource.fetch_status == 'successful'
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

  def update_gems skip_mail: false
    if update_gemsurance_report
      fix_gemsurance_report
      load_gems
      send_mail if !skip_mail && resource.reload.gem_status == :vulnerable
      true
    else
      false
    end
  end

  def load_gems
    ids_to_keep = []
    gems.each do |name, gem_data|
      ids_to_keep << load_gem(name, gem_data)
    end
    resource.gem_usages.where.not(id: ids_to_keep).destroy_all
    # because it's destroyed in a seperate ActiveRecord::Relation
    resource.send :clear_association_cache
  end

  def load_gem name, gem_data
    info = gem_info_for name, gem_data
    version = info.gem_versions.where(version: gem_data['bundle_version']).first_or_create!
    usage = resource.gem_usages.where(gem_version: version).first_or_initialize
    usage.in_gemfile = gem_data['in_gem_file']
    usage.save!
    gem_data['vulnerabilities'].try :each do |data|
      version.vulnerabilities.where(
        description: data['title'],
        cve: data['cve'],
        url: data['url'],
        patched_versions: data['patched_versions'],
      ).first_or_create!
    end
    usage.id
  end

  def gem_info_for name, gem_data
    info = GemInfo.where(name: name).first_or_initialize
    info.homepage_url = gem_data['homepage_url']
    info.source_code_url = gem_data['source_code_url']
    info.documentation_url = gem_data['documentation_url']
    info.save!
    if gem_data['newest_version'] != gem_data['bundle_version']
      info.gem_versions.where(version: gem_data['newest_version']).first_or_create!
    end
    info
  end

  def send_mail
    ResourceMailer.vulnerable_mail(resource).deliver_now
  end

  def fix_gemsurance_report
    content = File.readlines gemsurance_yaml_file
    content.each {|line| line.gsub!(/^( *[a-zA-Z0-9_]+): (>=.*)$/, '\1: "\2"') }
    File.write gemsurance_yaml_file, content.join
  end
end
