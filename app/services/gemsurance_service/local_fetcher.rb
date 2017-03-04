class GemsuranceService::LocalFetcher
  def self.update_gemsurance_report resource, file
    run_in_seperate_env "cd \"#{resource.path}\"; gemsurance --format yml --output \"#{file}\""
  end

  def self.errors resource
    e = []
    unless resource.path.blank?
      if File.exists? resource.path
        unless File.directory? resource.path
          e << [:path, :not_a_directory]
        end
      else
        e << [:path, :does_not_exist]
      end
    end
    e
  end

  private

  def self.run_in_seperate_env cmd
    system 'env', '-i', 'bash', '-l', '-c', cmd
  end
end
