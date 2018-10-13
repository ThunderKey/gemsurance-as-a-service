# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GitRepository, type: :unit do
  it 'a repository gets created correctly' do
    repo_path = File.join(Rails.application.config.test_tmp_dir, 'git', 'test_repo')
    repo = described_class.new repo_path
    allow(repo).to receive(:exec).with(
      '/usr/bin/git',
      'clone',
      'https://myremote.test/myrepo.git',
      repo_path,
    ).and_return(true)
    expect(repo.clone('https://myremote.test/myrepo.git')).to be true
  end

  it 'a repository gets pulled correctly' do
    repo_path = File.join(Rails.application.config.test_tmp_dir, 'git', 'test_repo')
    FileUtils.mkdir_p File.join(repo_path, '.git')
    repo = described_class.new repo_path
    expect(repo).to receive(:exec).with(
      '/usr/bin/git',
      '-C',
      repo_path,
      'pull',
      'origin',
      'master',
    ).and_return(true)
    expect(repo.pull).to be true
  end
end
