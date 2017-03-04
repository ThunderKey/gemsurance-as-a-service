class ResourcesController < ApplicationController
  def index
    @resources = Resource.all
  end

  def show
    @resource = Resource.find params[:id]
  end

  def new
    @resource = Resource.new
  end

  def update_data
    @resource = Resource.find params[:resource_id]
    UpdateResourceJob.perform_later @resource.id
    flash[:notice] = %Q{Started to update "#{@resource.name}"}
    redirect_back fallback_location: @resource
  end

  def create
    @resource = Resource.new resource_params
    if @resource.save
      flash[:notice] = %Q{Successfuly saved "#{@resource.name}"}
      redirect_to @resource
    else
      render :new
    end
  end

  def edit
    @resource = Resource.find params[:id]
  end

  def update
    @resource = Resource.find params[:id]
    @resource.update_attributes resource_params
    if @resource.save
      flash[:notice] = %Q{Successfuly saved "#{@resource.name}"}
      redirect_to @resource
    else
      render :edit
    end
  end

  def destroy
    @resource = Resource.find params[:id]
    @resource.destroy
    flash[:notice] = %Q{Successfuly deleted "#{@resource.name}"}
    redirect_to resources_path
  end

  private

  def resource_params
    params.require(:resource).permit(:name, :resource_type, :path, :build_url, :build_image_url)
  end
end
