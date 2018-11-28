# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'rake gemsurance:update' do
  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'updates the gems for each resource' do
    allow_any_instance_of(Resource).to receive(:start_update!)
    resources = Array.new(3) { create :resource, fetch_status: :successful }

    doubles = resources.map {|r| object_double(GemsuranceService.new(r), update_gems: true) }

    expect(GemsuranceService).to receive(:new).exactly(3).times.and_return(*doubles)

    task.execute

    expect(doubles).to all have_received(:update_gems)
  end

  it 'prints nothing if all are successful' do
    allow_any_instance_of(Resource).to receive(:start_update!)
    Array.new(3) { create :resource, fetch_status: :successful }

    allow_any_instance_of(GemsuranceService).to receive(:update_gems)

    expect do
      task.execute
    end.not_to output.to_stdout
  end

  it 'prints an error if all some are not successful' do
    allow_any_instance_of(Resource).to receive(:start_update!)

    create :resource, fetch_status: :successful
    pending_resource = create :resource, fetch_status: :pending
    failed_resource = create :resource, fetch_status: :failed, fetch_output: 'Some Error Output'
    create :resource, fetch_status: :successful

    allow_any_instance_of(GemsuranceService).to receive(:update_gems)

    expect do
      task.execute
    end.to output(<<-OUTPUT).to_stdout
Test App 2 (##{pending_resource.id}) has the status "pending" after the update:
Test App 3 (##{failed_resource.id}) has the status "failed" after the update:
Some Error Output
OUTPUT
  end
end
