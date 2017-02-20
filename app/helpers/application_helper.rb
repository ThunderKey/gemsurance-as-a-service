module ApplicationHelper
  def translate_flash_type type
    type = type.to_sym
    case type
      when :notice; :primary
      when :error;  :alert
      else type
    end
  end
end
