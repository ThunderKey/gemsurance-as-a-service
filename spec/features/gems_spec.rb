require 'rails_helper'

RSpec.feature '/gems', with_login: true do
  let(:base_url) { '/gems' }

  it 'displays all gems correctly' do
    gem_infos = 3.times.map { create(:gem_info) }

    gem_infos.each {|i| create :gem_version, gem_info: i }
    create :gem_version, gem_info: gem_infos.last

    visit base_url

    within '#all-gems' do
      expect(page).to have_text 'TestGem#1'
      expect(page).to have_text 'TestGem#2'
      expect(page).to have_text 'TestGem#3'
    end

    within '#current-gems' do
      expect(page).to have_text 'TestGem#1'
      expect(page).to have_text 'TestGem#2'
      expect(page).to_not have_text 'TestGem#3'
    end

    within '#outdated-gems' do
      expect(page).to_not have_text 'TestGem#1'
      expect(page).to_not have_text 'TestGem#2'
      expect(page).to have_text 'TestGem#3'
    end
  end

  context '/:id' do
    it 'displays the gem correctly' do
      gem_info = create :gem_info

      visit "#{base_url}/#{gem_info.id}"

      within 'h1' do
        expect(page).to have_content 'TestGem#1'
      end
    end

    context '/versions' do
      context '/:id' do
        it 'displays the gem version correctly' do
          gem_version = create :gem_version
          r = create :resource
          r.gem_usages.create gem_version: gem_version

          visit "#{base_url}/#{gem_version.gem_info.id}/versions/#{gem_version.id}"

          within '#main-content' do
            within 'h1' do
              expect(page).to have_link('TestGem#1', href: "/gems/#{gem_version.gem_info.id}")
              expect(page).to have_content ' - 1.2.3'
            end
            within 'table' do
              expect(page).to have_content 'Test App 1'
            end
            expect(page).to_not have_content 'Vulnerabilities'
          end
        end

        it 'displays a gem version with vulnerabilities correctly' do
          gem_version = create :gem_version
          gem_version.vulnerabilities.create description: 'Vulnerability 1'
          gem_version.vulnerabilities.create description: 'Vulnerability 2', url: 'https://example.com/vulnerability2'
          r = create :resource
          r.gem_usages.create gem_version: gem_version

          visit "#{base_url}/#{gem_version.gem_info.id}/versions/#{gem_version.id}"

          within '#main-content' do
            within 'h1' do
              expect(page).to have_link('TestGem#1', href: "/gems/#{gem_version.gem_info.id}")
              expect(page).to have_content ' - 1.2.3'
            end
            within 'table' do
              expect(page).to have_content 'Test App 1'
            end
            expect(page).to have_content 'Vulnerabilities'
            expect(page).to have_content 'Vulnerability 1'
            expect(page).to_not have_link 'Vulnerability 1'
            expect(page).to have_link('Vulnerability 2', href: 'https://example.com/vulnerability2')
          end
        end
      end
    end
  end
end
