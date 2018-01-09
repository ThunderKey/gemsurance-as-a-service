class Resource < ApplicationRecord
  include GemStatusSortable

  enum resource_type: Hash[GemsuranceService.fetchers.keys.map {|name| [name, name] }]
  enum fetch_status: Hash[[:pending, :successful, :failed].map {|k| [k, k.to_s] }]

  has_many :gem_usages, dependent: :destroy
  has_many :gem_versions, through: :gem_usages
  has_many :gem_infos, through: :gem_versions
  has_many :vulnerabilities, through: :gem_versions
  belongs_to :owner, class_name: 'User'

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
    self.fetch_output ||= ''
  end

  before_create { update_vulnerabilities_count }

  after_create { start_update! }

  def self.resource_type_attributes_for_select
    resource_types.keys.map do |resource_type|
      [I18n.t("activerecord.attributes.#{model_name.i18n_key}.resource_types.#{resource_type}"), resource_type]
    end
  end

  def update_vulnerabilities_count
    clear_association_cache
    self.vulnerabilities_count = vulnerabilities.reload.count
  end

  def update_vulnerabilities_count!
    update_vulnerabilities_count
    save!
  end

  def gem_status
    if vulnerabilities_count > 0
      :vulnerable
    else
      :current
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
