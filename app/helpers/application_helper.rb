module ApplicationHelper
  def build_image_tag resource
    img = image_tag resource.build_image_url, class: 'build-image'
    if resource.build_url.blank?
      img
    else
      link_to img, resource.build_url, target: '_blank'
    end
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
