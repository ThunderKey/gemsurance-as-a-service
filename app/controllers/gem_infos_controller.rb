class GemInfosController < ApplicationController
  include JsChartHelper

  def index
    @gem_infos = GemInfo.all
  end

  def show
    @gem_info = GemInfo.find params[:id]
    sorted = @gem_info.gem_versions.sort_by(&:version_object)
    @versions_data = transform_to_chart_data sorted.map {|v| {name: v.version, data: v.resources.count} }
  end
end
