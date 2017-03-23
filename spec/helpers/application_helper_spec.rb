require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#build_image_tag' do
    build_url = 'https://example.com/build'
    build_image_url = 'https://example.com/build.svg'

    it 'generates the image and the link if both are present' do
      resource = create :resource, build_url: build_url, build_image_url: build_image_url
      html = helper.build_image_tag resource
      expect(html).to eq %Q{<a target="_blank" href="#{build_url}"><img class="build-image" src="#{build_image_url}" alt="Build" /></a>}
    end

    it 'generates the image if the build url is missing' do
      resource = create :resource, build_image_url: build_image_url
      html = helper.build_image_tag resource
      expect(html).to eq %Q{<img class="build-image" src="#{build_image_url}" alt="Build" />}
    end

    it 'generates nothing if the build and image url is missing' do
      resource = create :resource
      html = helper.build_image_tag resource
      expect(html).to eq nil
    end

    it 'generates nothing if the image url is missing' do
      resource = create :resource, build_url: build_url
      html = helper.build_image_tag resource
      expect(html).to eq nil
    end
  end

  describe '#translate_flash_type' do
    it 'translates notice to primary' do
      expect(helper.translate_flash_type :notice).to eq :primary
    end

    it 'translates error to alert' do
      expect(helper.translate_flash_type :error).to eq :alert
    end

    it 'does not translate unknown keys' do
      expect(helper.translate_flash_type :test).to eq :test
    end
  end

  describe '#absolute_path_regex' do
    it { expect('/').to match helper.absolute_path_regex }
    it { expect('/test').to match helper.absolute_path_regex }
    it { expect('/test/directory/').to match helper.absolute_path_regex }
    it { expect('/test/directory/my-test_project.git').to match helper.absolute_path_regex }
    it { expect('/abcdefghijklmnop').to match helper.absolute_path_regex }
    it { expect('/qrstuvwxyz').to match helper.absolute_path_regex }
    it { expect('/0123456789').to match helper.absolute_path_regex }
    it { expect('/-_').to match helper.absolute_path_regex }
    it { expect('test/directory/').not_to match helper.absolute_path_regex }
    it { expect('/test /directory/').not_to match helper.absolute_path_regex }
  end

  describe '#gemsurance_regex' do
    describe 'matches' do
      it 'a minimal correct output' do
        expect(%Q{Retrieving gem version information...\nRetrieving latest vulnerability data...\nReading vulnerability data...\nGenerating report...\nGenerated report #{Rails.application.config.private_dir}/gemsurance_reports/1/gemsurance_report.yml.}).to match helper.gemsurance_regex
      end
      it 'a different formated correct output' do
        expect(<<-TXT).to match helper.gemsurance_regex

  Retrieving gem version information...
  Retrieving latest vulnerability data...
  Reading vulnerability data...
  Generating report...
  Generated report #{Rails.application.config.private_dir}/gemsurance_reports/1/gemsurance_report.yml.

TXT
      end
    end

    describe "doesn't match an output" do
      it 'with an invalid path' do
        expect(%Q{Retrieving gem version information...\nRetrieving latest vulnerability data...\nReading vulnerability data...\nGenerating report...\nGenerated report #{Rails.application.config.private_dir}/gemsurance_reports/1 /gemsurance_report.yml.}).not_to match helper.gemsurance_regex
      end

      it 'with only an error message' do
        expect(%Q{Could not find bunlder}).not_to match helper.gemsurance_regex
      end

      it 'with an additional error message' do
        expect(%Q{Retrieving gem version information...\nRetrieving latest vulnerability data...\nReading vulnerability data...\nGenerating report...\nGenerated report #{Rails.application.config.private_dir}/gemsurance_reports/1/gemsurance_report.yml.But something failed!}).not_to match helper.gemsurance_regex
      end
    end
  end
end
