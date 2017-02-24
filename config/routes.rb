Rails.application.routes.draw do
  root 'static#main'

  devise_for :users, controllers: {omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'users/sessions'}

  resources :resources
  resources :gems, only: [:index, :show] do
    resources :versions, controller: :gem_versions, only: [:show]
  end

  if Rails.env.test?
    get '/autologin/:user_id' => 'static#autologin'
  end
end
