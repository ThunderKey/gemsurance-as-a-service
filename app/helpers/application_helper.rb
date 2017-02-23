module ApplicationHelper
  def link_to_gem_source gem_info
    link_to gem_info.source_name, gem_info.full_source, title: gem_info.full_source, target: '_blank'
  end

  def translate_flash_type type
    type = type.to_sym
    case type
      when :notice; :primary
      when :error;  :alert
      else type
    end
  end
end
