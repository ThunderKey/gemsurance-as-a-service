class GemsuranceService
  class LocalFetcher < BaseFetcher
    def self.update_gemsurance_report resource, file
      run_in_seperate_env 'gemsurance', '--format', 'yml', '--output', file, chdir: resource.path
    end

    def self.errors resource
      e = []
      unless resource.path.blank?
        if File.exist? resource.path
          unless File.directory? resource.path
            e << [:path, :not_a_directory]
          end
        else
          e << [:path, :does_not_exist]
        end
      end
      e
    end
  end
end
