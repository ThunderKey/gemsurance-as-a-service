class GemInfosController < ApplicationController
  include JsChartHelper

  def index
    @gem_infos = GemInfo.includes(:gem_versions)
    @outdated_gem_infos = []
    @current_gem_infos = []
    @gem_infos.each do |info|
      if info.gem_versions.any?(&:outdated?)
        @outdated_gem_infos << info
      else
        @current_gem_infos << info
      end
    end
  end

  def show
    @gem_info = GemInfo.find params[:id]
    sorted = @gem_info.gem_versions.sort_by(&:version_object)
    @versions_data = transform_to_chart_data sorted.map {|v| {name: v.version, data: v.resources.count} }
  end
end
