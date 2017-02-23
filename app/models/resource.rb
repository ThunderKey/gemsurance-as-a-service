class Resource < ApplicationRecord
  enum resource_type: {local: 'local'}
  enum status: {pending: 'pending', uptodate: 'uptodate', outdated: 'outdated', vulnerable: 'vulnerable'}

  validates :name, presence: true
  validates :path, presence: true, format: {with: /\A\//, message: 'must be an absolute path' }
  validates :resource_type, presence: true

  before_save do
    self.status ||= :pending
  end

  validate do
    if resource_fetcher
      resource_fetcher.errors.each do |key, message|
        errors.add key, message
      end
    else
      errors.add :resource_type, 'does not have a valid resource fetcher'
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

  def description
    "#{resource_type}: #{path}"
  end
end
