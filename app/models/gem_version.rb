class GemVersion < ApplicationRecord
  belongs_to :gem_info
  has_many :gem_usage, dependent: :destroy
  has_many :resources, through: :gem_usage

  validates :version, presence: true, uniqueness: {scope: :gem_info}

  def self.sort_by_version dir = :asc
    sorted = all.sort_by {|gv| Gem::Version.new(gv.version) }
    dir == :asc ? sorted : sorted.reverse
  end

  def self.newest_version
    sort_by_version.last
  end
end
