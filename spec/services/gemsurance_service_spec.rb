require 'rails_helper'

RSpec.describe GemsuranceService, type: :service do
  # dir = File.join Rails.root, 'spec', 'tmp', 'private', 'gemsurance_reports', resource.id.to_s
  # expect(File.exists? gemsurance_report).to be false
  # expect(File.exists? gemsurance_report).to be true

  it 'includes valid fetchers' do
    expect(GemsuranceService.fetchers.keys).to eq ['local']
    GemsuranceService.fetchers.each do |name, fetcher|
      expect(fetcher).to respond_to :update_gemsurance_report
      expect(fetcher).to respond_to :errors
    end
  end

  it 'updates the gemsurance report correctly' do
    record = create :empty_local_resource
    service = GemsuranceService.new(record)

    expect {
      expect_any_instance_of(Kernel).to receive(:system).with 'env', '-i', 'bash', '-l', '-c', %Q{cd \"#{record.path}\"; gemsurance --format yml --output \"#{Rails.application.config.private_dir}/gemsurance_reports/1/gemsurance_report.yml\"}
      service.update_gemsurance_report
    }.to change { File.exists? service.dirname }.from(false).to(true)
  end

  it 'loads the gems correctly' do
    record = create :empty_local_resource
    service = GemsuranceService.new(record)
    create :gem_usage, resource: record
    expect(gem_usages_to_arrays record.gem_usages).to eq [
      ["TestGem#1", "1.2.3", false],
    ]
    expect(record.gem_usages.size).to be 1
    expect(record.gem_versions.size).to be 1
    expect(record.gem_infos.size).to be 1

    report_file = service.gemsurance_yaml_file
    expect{service.load_gems}.to raise_exception "No such file or directory @ rb_sysopen - #{report_file}"

    FileUtils.mkdir_p service.dirname
    FileUtils.cp File.join(Rails.root, 'spec', 'assets', 'simple_gemsurance_report.yml'), report_file

    service.load_gems

    expect(gem_usages_to_arrays record.gem_usages).to eq [
      ["actionpack", "5.0.1", false],
      ["actionview", "5.0.1", false],
      ["activesupport", "5.0.1", false],
      ["bcrypt", "3.1.11", false],
      ["builder", "3.2.3", false],
      ["bundler", "1.14.3", false],
      ["concurrent-ruby", "1.0.4", false],
      ["devise", "4.2.0", true],
      ["erubis", "2.7.0", false],
      ["faraday", "0.9.2", false],
      ["hashie", "3.4.4", false],
      ["i18n", "0.8.0", false],
      ["jwt", "1.5.4", false],
      ["loofah", "2.0.3", false],
      ["method_source", "0.8.2", false],
      ["mini_portile2", "2.1.0", false],
      ["minitest", "5.10.1", false],
      ["multi_json", "1.12.1", false],
      ["multi_xml", "0.5.5", false],
      ["multipart-post", "2.0.0", false],
      ["nokogiri", "1.6.8.1", false],
      ["oauth2", "1.2.0", false],
      ["omniauth", "1.3.1", false],
      ["omniauth-keltec", "0.0.1", true],
      ["omniauth-oauth2", "1.3.1", false],
      ["orm_adapter", "0.5.0", false],
      ["rack", "2.0.1", false],
      ["rack-test", "0.6.3", false],
      ["rails-dom-testing", "2.0.2", false],
      ["rails-html-sanitizer", "1.0.3", false],
      ["railties", "5.0.1", false],
      ["rake", "12.0.0", false],
      ["responders", "2.3.0", false],
      ["thor", "0.19.4", false],
      ["thread_safe", "0.3.5", false],
      ["tzinfo", "1.2.2", false],
      ["warden", "1.2.6", false],
    ]
    expect(record.gem_usages.size).to be 37
    expect(record.gem_versions.size).to be 37
    expect(record.gem_infos.size).to be 37
  end

  def gem_usages_to_arrays usages
    usages.map {|gu| [gu.gem_info.name, gu.gem_version.version, gu.in_gemfile] }
  end
end
