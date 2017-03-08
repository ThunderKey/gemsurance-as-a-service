require 'rails_helper'

RSpec.describe GemsuranceService, type: :service do
  it 'includes valid fetchers' do
    expect(GemsuranceService.fetchers.keys).to eq ['local']
    GemsuranceService.fetchers.each do |name, fetcher|
      expect(fetcher).to respond_to :update_gemsurance_report
      expect(fetcher).to respond_to :errors
    end
  end

  it 'calls the update and load methods in the correct order' do
    resource = create :empty_local_resource
    service = GemsuranceService.new(resource)

    expect(service).to receive(:update_gemsurance_report).ordered.and_return true
    expect(service).to receive(:fix_gemsurance_report).ordered
    expect(service).to receive(:load_gems).ordered
    service.update_gems
  end

  it 'updates the gemsurance report correctly' do
    resource = create :empty_local_resource
    service = GemsuranceService.new(resource)

    expect(resource.fetched_at).to eq nil
    expect(resource.fetch_output).to eq ""
    expect(resource.fetch_status).to eq "pending"

    Timecop.freeze

    report_file = "#{Rails.application.config.private_dir}/gemsurance_reports/1/gemsurance_report.yml"
    output = %Q{Retrieving gem version information...\nRetrieving latest vulnerability data...\nReading vulnerability data...\nGenerating report...\nGenerated report #{report_file}.}
    expect {
      expect(Open3).to receive(:capture2e).
        with(/\Aenv -i HOME="[^"]+" PATH="[^"]+" USER="[^"]+" GEM_HOME="[^"]+" GEM_PATH="[^"]+" gemsurance --format yml --output #{Regexp.escape report_file}/, {chdir: resource.path}).
        and_return([output, 0])
      service.update_gemsurance_report
    }.to change { File.exist? service.dirname }.from(false).to(true)

    expect(resource.fetched_at).to eq DateTime.now
    expect(resource.fetch_output).to eq output
    expect(resource.fetch_status).to eq 'successful'
  end

  it 'updates the status to failed if the command executes unsuccessful' do
    resource = create :empty_local_resource
    service = GemsuranceService.new(resource)

    expect(resource.fetched_at).to eq nil
    expect(resource.fetch_output).to eq ""
    expect(resource.fetch_status).to eq "pending"

    Timecop.freeze

    report_file = "#{Rails.application.config.private_dir}/gemsurance_reports/1/gemsurance_report.yml"
    output = %q{An error occured}
    expect {
      expect(Open3).to receive(:capture2e).
        with(/\Aenv -i HOME="[^"]+" PATH="[^"]+" USER="[^"]+" GEM_HOME="[^"]+" GEM_PATH="[^"]+" gemsurance --format yml --output #{Regexp.escape report_file}/, {chdir: resource.path}).
        and_return([output, 0])
      service.update_gemsurance_report
    }.to change { File.exist? service.dirname }.from(false).to(true)

    expect(resource.fetched_at).to eq DateTime.now
    expect(resource.fetch_output).to eq output
    expect(resource.fetch_status).to eq 'failed'
  end

  it 'loads the gems correctly' do
    resource = create :empty_local_resource
    service = GemsuranceService.new(resource)
    create :gem_usage, resource: resource
    expect(gem_usages_to_arrays resource.gem_usages).to eq [
      ['TestGem#1', '1.2.3', false],
    ]
    expect(resource.gem_usages.size).to be 1
    expect(resource.gem_versions.size).to be 1
    expect(resource.gem_infos.size).to be 1

    report_file = service.gemsurance_yaml_file
    expect{service.load_gems}.to raise_exception %Q{No such file or directory @ rb_sysopen - #{report_file}}

    FileUtils.mkdir_p service.dirname
    FileUtils.cp File.join(Rails.root, 'spec', 'assets', 'simple_gemsurance_report.yml'), report_file

    service.load_gems

    expect(gem_usages_to_arrays resource.gem_usages).to eq [
      ['actionpack', '5.0.1', false],
      ['actionview', '5.0.1', false],
      ['activesupport', '5.0.1', false],
      ['bcrypt', '3.1.11', false],
      ['builder', '3.2.3', false],
      ['bundler', '1.14.3', false],
      ['concurrent-ruby', '1.0.4', false],
      ['devise', '4.2.0', true],
      ['erubis', '2.7.0', false],
      ['faraday', '0.9.2', false],
      ['hashie', '3.4.4', false],
      ['i18n', '0.8.0', false],
      ['jwt', '1.5.4', false],
      ['loofah', '2.0.3', false],
      ['method_source', '0.8.2', false],
      ['mini_portile2', '2.1.0', false],
      ['minitest', '5.10.1', false],
      ['multi_json', '1.12.1', false],
      ['multi_xml', '0.5.5', false],
      ['multipart-post', '2.0.0', false],
      ['nokogiri', '1.6.8.1', false],
      ['oauth2', '1.2.0', false],
      ['omniauth', '1.3.1', false],
      ['omniauth-keltec', '0.0.1', true],
      ['omniauth-oauth2', '1.3.1', false],
      ['orm_adapter', '0.5.0', false],
      ['rack', '2.0.1', false],
      ['rack-test', '0.6.3', false],
      ['rails-dom-testing', '2.0.2', false],
      ['rails-html-sanitizer', '1.0.3', false],
      ['railties', '5.0.1', false],
      ['rake', '12.0.0', false],
      ['responders', '2.3.0', false],
      ['thor', '0.19.4', false],
      ['thread_safe', '0.3.5', false],
      ['tzinfo', '1.2.2', false],
      ['warden', '1.2.6', false],
    ]
    expect(resource.gem_usages.size).to be 37
    expect(resource.gem_versions.size).to be 37
    expect(resource.gem_infos.size).to be 37

    expect(resource.vulnerabilities).to eq []
  end

  it 'loads the gems with vulnerabilities correctly' do
    resource = create :empty_local_resource
    service = GemsuranceService.new(resource)
    report_file = service.gemsurance_yaml_file
    FileUtils.mkdir_p service.dirname
    FileUtils.cp File.join(Rails.root, 'spec', 'assets', 'vulnerable_gemsurance_report.yml'), report_file

    expect{service.load_gems}.to raise_error Psych::SyntaxError

    service.fix_gemsurance_report
    service.load_gems

    expect(gem_usages_to_arrays resource.gem_usages).to eq [
      ['actionpack', '3.2.22.5', false],
      ['activemodel', '3.2.22.5', false],
      ['activesupport', '3.2.22.5', false],
      ['bcrypt', '3.1.11', false],
      ['bcrypt-ruby', '3.1.5', false],
      ['builder', '3.0.4', false],
      ['bundler', '1.14.3', false],
      ['devise', '2.2.4', true],
      ['erubis', '2.7.0', false],
      ['faraday', '0.11.0', false],
      ['gems', '0.8.3', false],
      ['gemsurance', '0.8.0', true],
      ['git', '1.3.0', false],
      ['hashie', '3.5.5', false],
      ['hike', '1.2.3', false],
      ['i18n', '0.8.1', false],
      ['journey', '1.0.4', false],
      ['json', '1.8.6', false],
      ['jwt', '1.5.6', false],
      ['multi_json', '1.12.1', false],
      ['multi_xml', '0.6.0', false],
      ['multipart-post', '2.0.0', false],
      ['oauth2', '1.3.1', false],
      ['omniauth', '1.4.2', false],
      ['omniauth-keltec', '0.0.3', true],
      ['omniauth-oauth2', '1.4.0', false],
      ['orm_adapter', '0.5.0', false],
      ['rack', '1.4.7', false],
      ['rack-cache', '1.7.0', false],
      ['rack-ssl', '1.3.4', false],
      ['rack-test', '0.6.3', false],
      ['railties', '3.2.22.5', false],
      ['rake', '12.0.0', false],
      ['rdoc', '3.12.2', false],
      ['sprockets', '2.2.3', false],
      ['thor', '0.19.4', false],
      ['tilt', '1.4.1', false],
      ['warden', '1.2.7', false],
    ]

    expect(resource.vulnerabilities.map {|v| [v.description, v.cve, v.url, v.patched_versions] }).to eq [
      [
        'Devise Gem for Ruby Unauthorized Access Using Remember Me Cookie',
        '2015-8314',
        'http://blog.plataformatec.com.br/2016/01/improve-remember-me-cookie-expiration-in-devise/',
        '>= 3.5.4',
      ],
      [
        'CSRF token fixation attacks in Devise',
        nil,
        'http://blog.plataformatec.com.br/2013/08/csrf-token-fixation-attacks-in-devise/',
        '~> 2.2.5, >= 3.0.1',
      ],
    ]
  end

  def gem_usages_to_arrays usages
    usages.map {|gu| [gu.gem_info.name, gu.gem_version.version, gu.in_gemfile] }
  end
end
