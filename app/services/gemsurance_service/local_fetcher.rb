# frozen_string_literal: true

class GemsuranceService
  class LocalFetcher < BaseFetcher
    def self.update_gemsurance_report resource, file
      run_in_seperate_env 'gemsurance', '--format', 'yml', '--output', file, chdir: resource.path
    end

    def self.errors resource
      return {} if resource.path.blank?

      return {path: :does_not_exist} unless File.exist? resource.path

      return {path: :not_a_directory} unless File.directory? resource.path

      {}
    end
  end
end
