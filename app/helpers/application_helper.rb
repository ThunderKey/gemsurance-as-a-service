module ApplicationHelper
  @@absolute_path_content_regex = /\/(?:[\w\-\.]+\/)*[\w\-\.]*/
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

  def gem_status_tr status, color: true, &block
    content_tag 'tr', class: (color ? [status] : []), title: t(status, scope: 'gem_status'), &block
  end

  def translate_flash_type type
    type = type.to_sym
    case type
      when :notice; :primary
      when :error;  :alert
      else type
    end
  end

  # nil for relative and absolute URLs
  ALLOWED_PROTOCOLS = ['http', 'https', nil]
  def safe_url! url
    return url if url.blank?
    uri = URI.parse url
    return url if ALLOWED_PROTOCOLS.include? uri.scheme
    raise "Insecure URL scheme #{uri.scheme.inspect} (allowed: #{ALLOWED_PROTOCOLS.inspect})"
  end
end
