# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'gaas@keltec.ch'
  layout 'mailer'
end
