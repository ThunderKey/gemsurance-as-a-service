class GemsuranceService
  class LocalFetcher < BaseFetcher
    def self.update_gemsurance_report resource, file
      run_in_seperate_env 'gemsurance', '--format', 'yml', '--output', file, chdir: resource.path
    end

    def self.errors resource
      return {} if resource.path.blank?

      unless File.exist? resource.path
        return {path: :does_not_exist}
      end

      unless File.directory? resource.path
        return {path: :not_a_directory}
      end

      return {}
    end
  end
end
