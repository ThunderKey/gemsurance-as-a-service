class GemVersion < ApplicationRecord
  # TODO: Disabled until https://github.com/rails/rails/issues/28350 is fixed
  #include GemStatusSortable

  belongs_to :gem_info
  has_many :gem_usage, dependent: :destroy
  has_many :resources, through: :gem_usage
  has_many :vulnerabilities

  validates :version, presence: true, uniqueness: {scope: :gem_info}

  def self.sort_by_version dir = :asc
    sorted = all.sort_by &:version_object
    dir == :asc ? sorted : sorted.reverse
  end

  def self.newest_version
    sort_by_version.select do |gv|
      gv.version_object == gv.version_object.release
    end.last
  end

  def outdated?
    newest = gem_info.newest_gem_version
    !newest.nil? && version_object < newest.version_object
  end

  def version_object
    @version_object ||= Gem::Version.new version
  end

  def vulnerable?
    vulnerabilities.any?
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
end
