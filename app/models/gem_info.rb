class GemInfo < ApplicationRecord
  has_many :gem_versions, inverse_of: :gem_info, dependent: :destroy
  has_many :resources, through: :gem_versions

  validates :name, presence: true, uniqueness: true

  def newest_gem_version versions = nil
    versions ||= gem_versions
    versions.sort_by(&:version_object).reject {|v| v.version_object.prerelease? }.last
  end

  def update_all_gem_versions!
    update_gem_versions! { gem_versions }
  end

  def update_new_gem_versions!
    update_gem_versions! { gem_versions.not_outdated }
  end

  private

  def update_gem_versions!
    clear_association_cache
    versions = yield
    newest_gem_version = newest_gem_version(versions)&.version_object
    versions.each do |v|
      v.outdated = !newest_gem_version.nil? && v.version_object < newest_gem_version
      v.save!
    end
  end
end
