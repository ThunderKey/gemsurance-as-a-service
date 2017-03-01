class Resource < ApplicationRecord
  enum resource_type: Hash[ResourceFetcher.fetcher_names.map {|name| [name, name] }]
  enum status: {pending: 'pending', uptodate: 'uptodate', outdated: 'outdated', vulnerable: 'vulnerable'}

  has_many :gem_usages
  has_many :gem_versions, through: :gem_usages
  has_many :gem_infos, through: :gem_versions

  validates :name, presence: true, uniqueness: true
  validates :path, presence: true, format: {with: /\A\//, message: :relative_path}
  validates :resource_type, presence: true
  validates :build_image_url, format: {with: Rails.application.config.url_regex, message: :invalid_url, allow_blank: true}
  validates :build_url, format: {with: Rails.application.config.url_regex, message: :invalid_url, allow_blank: true}

  before_save do
    self.status ||= :pending
  end

  validate do
    if resource_type
      if resource_fetcher
        resource_fetcher.errors.each do |key, message|
          errors.add key, message
        end
      else
        errors.add :resource_type, 'does not have a valid resource fetcher'
      end
    end
  end

  def self.resource_type_attributes_for_select
    resource_types.map do |resource_type, key|
      [I18n.t("activerecord.attributes.#{model_name.i18n_key}.resource_types.#{resource_type}"), resource_type]
    end
  end

  def resource_fetcher
    ResourceFetcher.for self
  end

  def update_gems!
    fetcher = resource_fetcher
    raise "unknown fetcher for #{inspect}" unless fetcher
    fetcher.update_files
    ids_to_keep = []
    fetcher.gems.each do |name, gem_data|
      info = GemInfo.where(name: name, source: source_from_data(gem_data)).first_or_create
      version = GemVersion.where(gem_info: info, version: gem_data['version']).first_or_create
      usage = gem_usages.where(gem_version: version, in_gemfile: !!gem_data['in_gemfile']).first_or_create
      ids_to_keep << usage.id
    end
    gem_usages.where.not(id: ids_to_keep).destroy_all
    gem_usages.reload # because it's destroyed in a seperate ActiveRecord::Relation
  end

  private

  def source_from_data data
    source = data['source']
    case source['type']
    when 'rubygems'
      raise "Unknown remotes for rubygems: #{source['remotes'].inspect}" if source['remotes'] != [GemInfo::RUBYGEMS]
      GemInfo::RUBYGEMS
    when 'git'
      source['uri']
    else
      raise "Unknown source type: #{data.inspect}"
    end
  end
end
