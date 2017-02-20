class Resource < ApplicationRecord
  enum resource_type: {local: 'local'}
  enum status: {pending: 'pending', uptodate: 'uptodate', outdated: 'outdated', vulnerable: 'vulnerable'}

  validates :name, presence: true
  validates :path, presence: true
  validates :resource_type, presence: true

  before_save do
    self.status ||= :pending
  end

  def self.resource_type_attributes_for_select
    resource_types.map do |resource_type, key|
      [I18n.t("activerecord.attributes.#{model_name.i18n_key}.resource_types.#{resource_type}"), resource_type]
    end
  end

  def description
    "#{resource_type}: #{path}"
  end
end
