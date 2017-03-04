Rails.application.routes.draw do
  root 'static#main'

  devise_for :users, controllers: {omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'users/sessions'}

  resources :resources do
    put :update_data
  end
  resources :gems, only: [:index, :show] do
    resources :versions, controller: :gem_versions, only: [:show]
  end
end
