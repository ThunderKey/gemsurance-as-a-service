class GemUsage < ApplicationRecord
  belongs_to :gem_version
  belongs_to :resource

  validates :gem_version, uniqueness: {scope: :resource}
end
