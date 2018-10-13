# frozen_string_literal: true

module WithMailsHelpers
  def sent_mails
    ActionMailer::Base.deliveries
  end
end

RSpec.configure do |config|
  config.include WithMailsHelpers, with_mails: true

  config.before(with_mails: true) do
    sent_mails.clear
  end
end
