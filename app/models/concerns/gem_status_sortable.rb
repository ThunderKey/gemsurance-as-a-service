module GemStatusSortable
  extend ActiveSupport::Concern

  included do
    def numeric_gem_status
      case gem_status
      when :vulnerable; 0
      when :outdated; 1
      when :current; 2
      else raise "Unsupported gem_status #{gem_status.inspect}"
      end
    end
  end

  class_methods do
    def sort_by_gem_status dir = :asc
      case dir
      when :asc; all.to_a.sort_by(&:numeric_gem_status)
      when :desc; all.to_a.sort_by {|item| -item.numeric_gem_status }
      else; raise "Unknown direction #{dir.inspect}. Available: :asc and :desc"
      end
    end
  end
end
