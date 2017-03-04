class GitRepository
  class IllegalRepositoryError < IOError; end
  class RepositoryNotFoundError < IOError; end
  class RepositoryAlreadyClonedError < IOError; end
  class GitCommandFailedError < StandardError; end

  attr_reader :path, :remote, :branch

  def initialize path, remote: 'origin', branch: 'master'
    @path = path
    @remote = remote
    @branch = branch
  end

  def clone new_remote
    raise RepositoryAlreadyClonedError, "the repository #{path} is already checked out" if git_repository?
    raise IllegalRepositoryError, "the repository #{path} exists but is not valid" if path_exists?
    git_exec 'clone', new_remote, path
  end

  def path_exists?
    File.exists? path
  end

  def git_repository?
    path_exists? && File.exists?(File.join path, '.git')
  end

  def pull
    raise RepositoryNotFoundError, "the repository #{path} does not exist" unless git_repository?
    git_exec '-C', path, 'pull', remote, branch
  end

  private

  def git_exec *args
    exec Rails.application.config.git_command, *args
  end

  # :nocov:
  def exec *args
    #args << '&>/dev/null'
    unless system *args
      raise GitCommandFailedError, "the command #{args.inspect} failed"
    end
  end
  # :nocov:
end
