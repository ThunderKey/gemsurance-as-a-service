require 'rails_helper'

RSpec.describe UpdateResourceJob, type: :job do
  include ActiveJob::TestHelper

  subject(:resource) { create :local_resource }
  subject(:job) { described_class.perform_later(resource.id) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(described_class.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    dir = File.join Rails.root, 'spec', 'tmp', 'private', 'gemfiles', resource.id.to_s
    gemfile = File.join dir, 'Gemfile'
    lockfile = File.join dir, 'Gemfile.lock'
    expect(File.exists? gemfile).to be false
    expect(File.exists? lockfile).to be false
    perform_enqueued_jobs { job }
    expect(File.exists? gemfile).to be true
    expect(File.exists? lockfile).to be true
  end

  it 'handles no results error' do
    resource.path = File.join Rails.root, 'spec', 'tmp', 'nonexisting'
    resource.save! validate: false

    perform_enqueued_jobs do
      expect_any_instance_of(described_class).not_to receive(:retry_job)

      expect { job }.to raise_error Errno::ENOENT
    end
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
