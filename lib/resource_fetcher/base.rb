module ResourceFetcher
  class Base
    attr_reader :resource, :gemfile, :lockfile

    def initialize resource, gemfile: 'Gemfile', lockfile: 'Gemfile.lock'
      @resource = resource
      @gemfile = gemfile
      @lockfile = lockfile
    end

    def dirname
      @dirname ||= begin
        resource_id = resource.id.to_s
        raise "id of the resource is empty: #{resource.inspect}" if resource_id.blank?
        d = File.join Rails.application.config.gemfile_dir, resource_id
        FileUtils.mkdir_p d
        d
      end
    end

    def update_files
      reset!
    end

    def errors
      []
    end

    def reset!
      @gems = nil
    end

    def gems
      @gems ||= begin
        interpreter = GemfileInterpreter.new(dirname, gemfile: gemfile, lockfile: lockfile)
        interpreter.parsed
      end
    end
  end
end
