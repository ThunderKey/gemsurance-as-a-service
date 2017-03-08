module ApplicationHelper
  @@absolute_path_content_regex = /\/(?:[\w-]+\/)*[\w-]*/
  @@absolute_path_regex = /\A#{@@absolute_path_content_regex}\z/
  @@gemsurance_regex = /\A\s*Retrieving gem version information\.\.\.\s+Retrieving latest vulnerability data\.\.\.\s+Reading vulnerability data\.\.\.\s+Generating report\.\.\.\s+Generated report #{Rails.application.config.private_dir}\/gemsurance_reports\/\d+\/gemsurance_report\.yml\.\s*\Z/

  def self.absolute_path_regex() @@absolute_path_regex; end
  def self.gemsurance_regex() @@gemsurance_regex; end
  def absolute_path_regex() @@absolute_path_regex; end
  def gemsurance_regex() @@gemsurance_regex; end

  def build_image_tag resource
    return nil if resource.build_image_url.blank?
    img = image_tag resource.build_image_url, class: 'build-image'
    if resource.build_url.blank?
      img
    else
      link_to img, resource.build_url, target: '_blank'
    end
  end

  def gem_status_tr status, &block
    content_tag 'tr', class: [status], title: t(status, scope: 'gem_status'), &block
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
