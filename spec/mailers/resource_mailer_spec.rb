# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResourceMailer do
  context '#vulnerable_mail' do
    let(:resource) do
      create :resource do |r|
        create :gem_usage, :vulnerable, resource: r
      end
    end

    let(:mail) { ResourceMailer.vulnerable_mail resource }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Vulnerabilities in Test App 1'
      expect(mail.to).to eq ['peter.tester.1@example.com']
      expect(mail.from).to eq ['gaas@keltec.ch']
      expect(mail.cc).to eq nil
      expect(mail.bcc).to eq nil
    end

    it 'renders the body' do
      expect(ActionController::Base.helpers.strip_tags(mail.body.encoded)).to eq <<-BODY.chomp
Hi Peter TesterThe following gems are insecure and is used in your resource Test App 1TestGem#4 - 4.5.6: Example VulnerabilityGreetings, Gemsurance As A Service
BODY
    end
  end
end
