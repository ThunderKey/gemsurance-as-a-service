module ResourceFetcher
  class Local < Base
    def update_files
      copy_from_resource gemfile
      copy_from_resource lockfile
      super
    end

    def errors
      e = super
      if File.exists? resource.path
        if File.directory? resource.path
          validate_file e, gemfile
          validate_file e, lockfile
        else
          e << [:path, :not_a_directory]#'is not a directory']
        end
      else
        e << [:path, :does_not_exist]#'does not exist']
      end
      e
    end

    private

    def validate_file e, filename
      unless File.exists? File.join(resource.path, filename)
        e << [:path, I18n.t(:file_missing, scope: 'activerecord.errors.models.resource.attributes.path', filename: filename)]
      end
    end

    def copy_from_resource filename
      FileUtils.cp File.join(resource.path, filename), File.join(dirname, filename)
    end
  end

  register 'local', Local
end
