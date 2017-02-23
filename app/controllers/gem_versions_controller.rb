class GemVersionsController < ApplicationController
  def show
    @gem_version = GemInfo.find(params[:gem_id]).gem_versions.find params[:id]
  end
end
