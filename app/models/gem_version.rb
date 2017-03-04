class GemVersion < ApplicationRecord
  belongs_to :gem_info
  has_many :gem_usage, dependent: :destroy
  has_many :resources, through: :gem_usage

  validates :version, presence: true, uniqueness: {scope: :gem_info}
end
