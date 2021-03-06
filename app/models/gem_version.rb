# frozen_string_literal: true

class GemVersion < ApplicationRecord
  include GemStatusSortable

  belongs_to :gem_info, inverse_of: :gem_versions
  has_many :gem_usages, dependent: :destroy
  has_many :resources, through: :gem_usages
  has_many :vulnerabilities, dependent: :destroy

  validates :version, presence: true, uniqueness: {scope: :gem_info}

  after_create do
    gem_info.update_new_gem_versions!
    reload
  end
  after_destroy { gem_info.update_all_gem_versions! }

  scope :outdated, -> { where(outdated: true) }
  scope :not_outdated, -> { where(outdated: [false, nil]) }

  def outdated?
    raise 'the GemInfo#update_new_gem_versions! did not get called!' if outdated.nil?

    outdated
  end

  def version_object
    @version_object ||= Gem::Version.new version
  end

  def vulnerable?
    vulnerabilities_count.positive?
  end

  def gem_status
    if vulnerable?
      :vulnerable
    elsif outdated?
      :outdated
    else
      :current
    end
  end

  def destroy_if_not_used
    clear_association_cache
    destroy if gem_info.newest_gem_version != self && gem_usages.empty?
  end

  private

  def outdated
    self[:outdated]
  end
end
