Rails.application.routes.draw do
  root 'static#main'

  devise_for :users, controllers: {omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'users/sessions'}

  resources :resources do
    put :update_data
  end
  resources :gem_infos, path: '/gems', only: [:index, :show]
  resources :gem_versions, path: '/gems/:gem_info_id/versions', only: [:show]
end
