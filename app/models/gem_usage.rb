class GemUsage < ApplicationRecord
  include GemStatusSortable

  belongs_to :gem_version
  belongs_to :resource
  has_one :gem_info, through: :gem_version
  has_many :vulnerabilities, through: :gem_version

  after_create  { resource.update_vulnerabilities_count! }
  after_destroy { resource.update_vulnerabilities_count! }

  after_destroy do
    gem_version.destroy_if_not_used
  end

  validates :gem_version, uniqueness: {scope: :resource}

  validate do
    errors.add :in_gemfile, :blank if in_gemfile.nil?
  end

  delegate :gem_status, to: :gem_version
end
