class GemInfo < ApplicationRecord
  has_many :gem_versions, dependent: :destroy
  has_many :resources, through: :gem_versions

  validates :name, presence: true, uniqueness: true
end
