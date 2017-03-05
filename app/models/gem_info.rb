class GemInfo < ApplicationRecord
  has_many :gem_versions, dependent: :destroy
  has_many :resources, through: :gem_versions

  validates :name, presence: true, uniqueness: true

  def newest_gem_version
    gem_versions.newest_version
  end
end
