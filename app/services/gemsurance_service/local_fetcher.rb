class GemsuranceService::LocalFetcher
  def self.update_gemsurance_report resource, file
    run_in_seperate_env %Q{bundle exec gemsurance --format yml --output "#{file}"}, resource.path
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

  def self.run_in_seperate_env cmd, dir
    Open3.capture2e('env', '-i', 'bash', '-l', '-c', cmd, chdir: dir)
  end
end
