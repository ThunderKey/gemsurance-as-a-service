require 'rails_helper'
# https://everydayrails.com/2012/04/07/testing-series-rspec-controllers.html

describe ResourcesController do
  valid_path = File.join Rails.root, 'spec', 'assets', 'valid_app'

  before :each do
    stub_devise
  end

  describe 'GET #index' do
    it 'displays 0 resources' do
      get :index
      expect(assigns(:resources)).to eq []
    end

    it 'displays 3 resources' do
      r1 = create :resource
      r2 = create :resource
      r3 = create :resource

      get :index
      expect(assigns(:resources)).to eq [r1, r2, r3]
    end

    it 'renders the :index view' do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    it 'assigns the requested resource to @resource' do
      resource = create :resource
      get :show, params: {id: resource}
      expect(assigns(:resource)).to eq(resource)
    end

    it 'renders the #show view' do
      get :show, params: {id: create(:resource)}
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    it 'hands you an empty resource' do
      get :new
      expect(assigns(:resource).attributes).to eq Resource.new.attributes
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested resource to @resource' do
      resource = create :resource
      get :edit, params: {id: resource}
      expect(assigns(:resource)).to eq(resource)
    end

    it 'renders the #edit view' do
      get :edit, params: {id: create(:resource)}
      expect(response).to render_template :edit
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new resource' do
        expect{
          post :create, params: {resource: attributes_for(:resource)}
        }.to change(Resource,:count).by(1)
        resource = assigns :resource
        expect(resource.name).to match /\ATest App \d+\z/
        expect(resource.resource_type).to eq 'local'
        expect(resource.path).to eq valid_path
        expect(resource.build_url).to eq nil
        expect(resource.build_image_url).to eq nil
      end

      it 'creates a new resource with optional attributes' do
        expect{
          post :create, params: {resource: attributes_for(:resource), build_url: 'https://test.test/project/1', build_image_url: 'https://test.test/project/1.svg'}
        }.to change(Resource,:count).by(1)
        resource = assigns :resource
        expect(resource.name).to match /\ATest App \d+\z/
        expect(resource.resource_type).to eq 'local'
        expect(resource.path).to eq valid_path
        expect(resource.build_url).to eq nil
        expect(resource.build_image_url).to eq nil
      end

      it 'redirects to the new resource' do
        post :create, params: {resource: attributes_for(:resource)}
        expect(response).to redirect_to Resource.last
      end
    end

    context 'with invalid attributes' do
      it 'does not save the new resource' do
        expect{
          post :create, params: {resource: attributes_for(:invalid_resource)}
        }.to_not change(Resource,:count)
      end

      it 're-renders the new method' do
        post :create, params: {resource: attributes_for(:invalid_resource)}
        expect(response).to render_template :new
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @resource = create :resource, name: 'MyTestApp'
      @valid_path = @resource.path
    end

    context 'valid attributes' do
      it 'located the requested @resource' do
        put :update, params: {id: @resource, resource: attributes_for(:resource)}
        expect(assigns(:resource)).to eq(@resource)
      end

      it 'changes @resource\'s attributes' do
        put :update, params: {id: @resource,
          resource: attributes_for(:resource, name: 'MyOtherTestApp', path: @valid_path)}
        @resource.reload
        expect(@resource.name).to eq('MyOtherTestApp')
        expect(@resource.path).to eq(@valid_path)
        expect(@resource.build_url).to eq nil
        expect(@resource.build_image_url).to eq nil
      end

      it 'changes @resource\'s optional attributes' do
        put :update, params: {id: @resource,
          resource: {build_url: 'https://test.test/project/1', build_image_url: 'https://test.test/project/1.svg'}}
        @resource.reload
        expect(@resource.build_url).to eq 'https://test.test/project/1'
        expect(@resource.build_image_url).to eq 'https://test.test/project/1.svg'
      end

      it 'redirects to the updated resource' do
        put :update, params: {id: @resource, resource: attributes_for(:resource)}
        expect(response).to redirect_to @resource
      end
    end

    context 'invalid attributes' do
      it 'locates the requested @resource' do
        put :update, params: {id: @resource, resource: attributes_for(:invalid_resource)}
        expect(assigns(:resource)).to eq(@resource)
      end

      it 'does not change @resource\'s attributes' do
        put :update, params: {id: @resource,
          resource: attributes_for(:resource, name: 'MyOtherTestApp', path: nil)}
        @resource.reload
        expect(@resource.name).to_not eq('MyOtherTestApp')
        expect(@resource.path).to eq(@valid_path)
      end

      it 're-renders the edit method' do
        put :update, params: {id: @resource, resource: attributes_for(:invalid_resource)}
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @resource = create :resource
    end

    it "deletes the resource" do
      expect{
        delete :destroy, params: {id: @resource}
      }.to change(Resource,:count).by(-1)
    end

    it "redirects to resources#index" do
      delete :destroy, params: {id: @resource}
      expect(response).to redirect_to resources_url
    end
  end

  describe 'PUT #update_data' do
    before :each do
      @resource = create :resource
    end

    it 'calls the update resource job' do
      ActiveJob::Base.queue_adapter = :test

      expect {
        put :update_data, params: {resource_id: @resource}
      }.to have_enqueued_job(UpdateResourceJob).with(@resource.id)

      expect(flash.notice).to eq %Q{Started to update "Test App 1"}
    end
  end
end
