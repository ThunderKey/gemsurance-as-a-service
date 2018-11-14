# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateResourceJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later(resource.id) }

  let(:resource) { create :resource }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job' do
    expect { resource }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(described_class.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    resource # create it first so the auto update task is not executed
    expect_any_instance_of(GemsuranceService).to receive(:update_gems).with no_args
    perform_enqueued_jobs { job }
  end
end
