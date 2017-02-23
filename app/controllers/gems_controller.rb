class GemsController < ApplicationController
  def index
    @gem_infos = GemInfo.all
  end

  def show
    @gem_info = GemInfo.find params[:id]
  end
end
