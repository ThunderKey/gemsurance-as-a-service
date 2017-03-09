class VulnerabilitiesController < ApplicationController
  def index
    @vulnerabilities = Vulnerability.joins(:resources)
  end
end
