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
end
