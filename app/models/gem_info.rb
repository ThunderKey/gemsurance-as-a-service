class GemInfo < ApplicationRecord
  has_many :gem_versions
  has_many :resources, through: :gem_versions

  RUBYGEMS = 'https://rubygems.org/'

  validates :name, presence: true, uniqueness: {scope: :source}
  validates :source, presence: true

  def full_source
    source == RUBYGEMS ? "#{source}gems/#{name}" : source
  end

  def source_name
    case source
    when RUBYGEMS
      'RubyGems'
    when /github/
      'GitHub'
    else
      source
    end
  end
end
