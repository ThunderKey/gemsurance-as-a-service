# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GemsuranceService, type: :service do
  it 'includes valid fetchers' do
    expect(described_class.fetchers.keys).to eq ['local']
    described_class.fetchers.each do |_name, fetcher|
      expect(fetcher).to respond_to :update_gemsurance_report
      expect(fetcher).to respond_to :errors
    end
  end

  describe '#update_gems', with_mails: true do
    it 'calls the update and load methods in the correct order' do
      resource = create :empty_local_resource
      service = described_class.new(resource)

      expect(service).to receive(:update_gemsurance_report).ordered.and_return true
      expect(service).to receive(:fix_gemsurance_report).ordered
      expect(service).to receive(:load_gems).ordered
      expect(service.update_gems).to eq true
    end

    it 'does not call load methods if the update fails' do
      resource = create :empty_local_resource
      service = described_class.new(resource)

      expect(service).to receive(:update_gemsurance_report).and_return false
      expect(service).not_to receive(:fix_gemsurance_report)
      expect(service).not_to receive(:load_gems)
      expect(service.update_gems).to eq false
    end

    it 'sends a mail if the resource is vulnerable' do
      resource = create :resource
      create :vulnerability, gem_version: resource.gem_versions.first!
      service = described_class.new(resource)

      expect(service).to receive(:update_gemsurance_report).and_return true
      expect(service).to receive(:fix_gemsurance_report)
      expect(service).to receive(:load_gems)
      expect(ResourceMailer).to receive(:vulnerable_mail).and_call_original
      expect do
        expect(service.update_gems).to eq true
      end.to change(ActionMailer::Base.deliveries, :count).by 1

      mail = sent_mails.last
      expect(mail.subject).to eq 'Vulnerabilities in Test App 1'
      expect(mail.to).to eq ['peter.tester.1@example.com']
      expect(mail.from).to eq ['gaas@keltec.ch']
      expect(mail.cc).to eq nil
      expect(mail.bcc).to eq nil
      expect(mail.body.encoded).to match /TestGem#1/
    end
  end

  describe '#update_gemsurance_report' do
    it 'updates the gemsurance report correctly' do
      resource = create :empty_local_resource
      service = described_class.new(resource)

      expect(resource.fetched_at).to eq nil
      expect(resource.fetch_output).to eq ''
      expect(resource.fetch_status).to eq 'pending'

      Timecop.freeze

      report_file = Rails.application.config.private_dir.join(
        'gemsurance_reports',
        resource.id.to_s,
        'gemsurance_report.yml',
      )
      output = "Retrieving gem version information...
Retrieving latest vulnerability data...
Reading vulnerability data...
Generating report...
Generated report #{report_file}."
      expect do
        expect(Open3).to receive(:capture2e)
          .with(
            /\Aenv -i HOME="[^"]+" PATH="[^"]+" USER="[^"]+" GEM_HOME="[^"]+" GEM_PATH="[^"]+" gemsurance --format yml --output #{Regexp.escape report_file.to_s}/, # rubocop:disable Metrics/LineLength
            chdir: resource.path,
          )
          .and_return([output, 0])
        service.update_gemsurance_report
      end.to change { File.exist? service.dirname }.from(false).to(true)

      expect(resource.fetched_at).to eq Time.zone.now.change(usec: 0)
      expect(resource.fetch_output).to eq output
      expect(resource.fetch_status).to eq 'successful'
    end

    it 'updates the status to failed if the command executes unsuccessful' do
      resource = create :empty_local_resource
      service = described_class.new(resource)

      expect(resource.fetched_at).to eq nil
      expect(resource.fetch_output).to eq ''
      expect(resource.fetch_status).to eq 'pending'

      Timecop.freeze

      report_file = Rails.application.config.private_dir.join(
        'gemsurance_reports',
        resource.id.to_s,
        'gemsurance_report.yml',
      )
      output = 'An error occured'
      expect do
        expect(Open3).to receive(:capture2e)
          .with(
            /\Aenv -i HOME="[^"]+" PATH="[^"]+" USER="[^"]+" GEM_HOME="[^"]+" GEM_PATH="[^"]+" gemsurance --format yml --output #{Regexp.escape report_file.to_s}/, # rubocop:disable Metrics/LineLength
            chdir: resource.path,
          )
          .and_return([output, 0])
        service.update_gemsurance_report
      end.to change { File.exist? service.dirname }.from(false).to(true)

      expect(resource.fetched_at).to eq Time.zone.now.change(usec: 0)
      expect(resource.fetch_output).to eq output
      expect(resource.fetch_status).to eq 'failed'
    end
  end

  describe '#load_gems' do
    it 'loads the gems correctly' do
      resource = create :empty_local_resource
      service = described_class.new(resource)
      create :gem_usage, resource: resource
      expect(gem_usages_to_arrays(resource.gem_usages)).to eq [
        ['TestGem#1', '1.2.3', false],
      ]
      expect(resource.gem_usages.size).to eq 1
      expect(resource.gem_versions.size).to eq 1
      expect(resource.gem_infos.size).to eq 1

      report_file = service.gemsurance_yaml_file
      expect {service.load_gems}
        .to raise_exception "No such file or directory @ rb_sysopen - #{report_file}"

      FileUtils.mkdir_p service.dirname
      FileUtils.cp Rails.root.join('spec', 'assets', 'simple_gemsurance_report.yml'), report_file

      service.load_gems

      expect(gem_usages_to_arrays(resource.gem_usages)).to eq [
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
      service = described_class.new(resource)
      report_file = service.gemsurance_yaml_file
      FileUtils.mkdir_p service.dirname
      FileUtils.cp Rails.root.join('spec', 'assets', 'vulnerable_gemsurance_report.yml'),
        report_file

      expect {service.load_gems}.to raise_error Psych::SyntaxError

      service.fix_gemsurance_report
      service.load_gems

      expect(gem_usages_to_arrays(resource.gem_usages)).to eq [
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

      expect(resource.vulnerabilities.map {|v| [v.description, v.cve, v.url, v.patched_versions] })
        .to eq [
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
end
