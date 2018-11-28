# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'rake gemsurance:fix_invalid_versions' do
  before do
    3.times do |i|
      info = create :gem_info
      (i + 1).times { create :gem_version, gem_info: info }
    end
  end

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'does not update the gem versions if all are valid' do
    expect_any_instance_of(GemInfo).not_to receive(:update_all_gem_versions!)

    expect { task.execute }.not_to output.to_stdout
  end

  it 'updates the gem versions if its invalid' do
    expect_any_instance_of(GemInfo).to receive(:update_all_gem_versions!)

    gem_info = GemInfo.last
    # dont execute update_new_gem_versions!
    expect(gem_info).to receive(:update_new_gem_versions!)
    create :gem_version, gem_info: gem_info

    expect { task.execute }.to output.to_stdout
  end

  it 'updates multiple gem versions if they are invalid' do
    allow_any_instance_of(GemInfo).to receive(:update_all_gem_versions!)

    GemInfo.last(2).each do |gem_info|
      # dont execute update_new_gem_versions!
      expect(gem_info).to receive(:update_new_gem_versions!)
      create :gem_version, gem_info: gem_info
    end

    expect { task.execute }.to output(<<-OUTPUT).to_stdout
Too many gem versions for TestGem#2:
\t3.4.5
\t7.8.9
Fixed
Too many gem versions for TestGem#3:
\t6.7.8
\t8.9.10
Fixed
OUTPUT
  end
end
