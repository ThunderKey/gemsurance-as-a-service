# frozen_string_literal: true

class ResourceMailer < ApplicationMailer
  def vulnerable_mail resource
    @resource = resource
    @user = resource.owner

    mail to: @user.email, subject: "Vulnerabilities in #{@resource.name}"
  end
end
