class Resource < ApplicationRecord
  enum resource_type: Hash[GemsuranceService.fetchers.keys.map {|name| [name, name] }]
  enum fetch_status: Hash[[:pending, :successful, :failed].map {|k| [k, k.to_s] }]

  has_many :gem_usages
  has_many :gem_versions, through: :gem_usages
  has_many :gem_infos, through: :gem_versions
  has_many :vulnerabilities, through: :gem_versions

  validates :name, presence: true, uniqueness: true
  validates :path, presence: true, format: {with: ApplicationHelper.absolute_path_regex, message: :relative_path}
  validates :resource_type, presence: true
  validates :build_image_url, format: {with: Rails.application.config.url_regex, message: :invalid_url, allow_blank: true}
  validates :build_url, format: {with: Rails.application.config.url_regex, message: :invalid_url, allow_blank: true}

  validate do
    if resource_type
      gemsurance_service.errors.each {|k,m| errors.add k, m }
    end
  end

  before_save do
    self.fetch_status ||= :pending
  end

  def self.resource_type_attributes_for_select
    resource_types.map do |resource_type, key|
      [I18n.t("activerecord.attributes.#{model_name.i18n_key}.resource_types.#{resource_type}"), resource_type]
    end
  end

  def self.sort_by_gems_status dir = :asc
    if dir == :asc
      sort_by(&:numeric_gems_status)
    else
      sort_by(&:numeric_gems_status).reverse
    end
  end

  def gems_status
    if vulnerabilities.any?
      :vulnerable
    elsif gem_versions.any? &:outdated?
      :outdated
    else
      :current
    end
  end

  def numeric_gems_status
    case gems_status
    when :vulnerable; 0
    when :outdated; 1
    when :current; 2
    else raise "Unsupported gems_status #{gems_status.inspect}"
    end
  end

  def gemsurance_service
    @gemsurance_service ||= GemsuranceService.new self
  end

  def start_update!
    self.fetch_status = :pending
    save!
    UpdateResourceJob.perform_later id
  end
end
