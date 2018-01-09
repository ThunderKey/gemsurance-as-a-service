class GemVersion < ApplicationRecord
  include GemStatusSortable

  belongs_to :gem_info, inverse_of: :gem_versions
  has_many :gem_usage, dependent: :destroy
  has_many :resources, through: :gem_usage
  has_many :vulnerabilities, count_loader: true, dependent: :destroy

  validates :version, presence: true, uniqueness: {scope: :gem_info}

  after_create { gem_info.update_new_gem_versions!; reload }
  after_destroy { gem_info.update_all_gem_versions! }

  scope :outdated, ->() {
    where(outdated: true)
  }

  scope :not_outdated, ->() {
    where(outdated: [false, nil])
  }

  def outdated?
    raise 'the GemInfo#update_new_gem_versions! did not get called!' if outdated.nil?
    outdated
  end

  def version_object
    @version_object ||= Gem::Version.new version
  end

  def vulnerable?
    vulnerabilities_count > 0
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

  private

  def outdated
    self[:outdated]
  end
end
