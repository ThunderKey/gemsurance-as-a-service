module RubyAdvisoryDatabaseFetcher
  REPOSITORY = GitRepository.new(Rails.application.config.ruby_advisory_database_dir)

  def self.update
    if REPOSITORY.git_repository?
      REPOSITORY.pull
    else
      REPOSITORY.clone Rails.application.config.ruby_advisory_database_repository
    end
  end
end
