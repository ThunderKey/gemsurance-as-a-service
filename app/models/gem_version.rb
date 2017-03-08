class GemVersion < ApplicationRecord
  # TODO: Disabled until https://github.com/rails/rails/issues/28350 is fixed
  #include GemStatusSortable

  belongs_to :gem_info
  has_many :gem_usage, dependent: :destroy
  has_many :resources, through: :gem_usage
  has_many :vulnerabilities

  validates :version, presence: true, uniqueness: {scope: :gem_info}

  def self.sort_by_version dir = :asc
    sorted = all.sort_by {|gv| Gem::Version.new(gv.version) }
    dir == :asc ? sorted : sorted.reverse
  end

  def self.newest_version
    sort_by_version.last
  end

  def outdated?
    version != gem_info.newest_gem_version.version
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
