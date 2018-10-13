# frozen_string_literal: true

class GitRepository
  class IllegalRepositoryError < IOError
    def initialize path
      super "the repository #{path} exists but is not valid"
    end
  end
  class RepositoryNotFoundError < IOError
    def initialize path
      super "the repository #{path} does not exist"
    end
  end
  class RepositoryAlreadyClonedError < IOError
    def initialize path
      super "the repository #{path} is already checked out"
    end
  end
  class GitCommandFailedError < StandardError
    def initialize args
      super "the command #{args.inspect} failed"
    end
  end

  attr_reader :path, :remote, :branch

  def initialize path, remote: 'origin', branch: 'master'
    @path = path
    @remote = remote
    @branch = branch
  end

  def clone new_remote
    raise RepositoryAlreadyClonedError, path if git_repository?
    raise IllegalRepositoryError, path if path_exists?

    git_exec 'clone', new_remote, path
  end

  def path_exists?
    File.exist? path
  end

  def git_repository?
    path_exists? && File.exist?(File.join(path, '.git'))
  end

  def pull
    raise RepositoryNotFoundError, path unless git_repository?

    git_exec '-C', path, 'pull', remote, branch
  end

  private

  def git_exec *args
    exec Rails.application.config.git_command, *args
  end

  # :nocov:
  def exec *args
    # args << '&>/dev/null'
    raise GitCommandFailedError, args unless system(*args)
  end
  # :nocov:
end
