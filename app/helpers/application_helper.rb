# frozen_string_literal: true

module ApplicationHelper
  ABSOLUTE_PATH_CONTENT_REGEX = %r{/(?:[\w\-\.]+/)*[\w\-\.]*}.freeze
  class_variable_set '@@absolute_path_regex', /\A#{ABSOLUTE_PATH_CONTENT_REGEX}\z/
  class_variable_set '@@gemsurance_regex', %r{\A\s*Retrieving gem version information\.\.\.\s+Retrieving latest vulnerability data\.\.\.\s+Reading vulnerability data\.\.\.\s+Generating report\.\.\.\s+Generated report #{Rails.application.config.private_dir}/gemsurance_reports/\d+/gemsurance_report\.yml\.\s*\Z} # rubocop:disable Metrics/LineLength

  cattr_reader :absolute_path_regex
  cattr_reader :gemsurance_regex

  def build_image_tag resource
    return nil if resource.build_image_url.blank?

    img = image_tag resource.build_image_url, class: 'build-image', alt: 'Build'
    if resource.build_url.blank?
      img
    else
      link_to img, resource.build_url, target: '_blank', rel: 'noopener'
    end
  end

  def gem_status_tr status, color: true, &block
    content_tag 'tr', class: (color ? [status] : []), title: t(status, scope: 'gem_status'), &block
  end

  def translate_flash_type type
    type = type.to_sym
    case type
    when :notice then :primary
    when :error then  :alert
      else type
    end
  end

  # nil for relative and absolute URLs
  ALLOWED_PROTOCOLS = ['http', 'https', nil].freeze
  def safe_url! url
    return url if url.blank?

    uri = URI.parse url
    return url if ALLOWED_PROTOCOLS.include? uri.scheme

    raise "Insecure URL scheme #{uri.scheme.inspect} (allowed: #{ALLOWED_PROTOCOLS.inspect})"
  end
end
