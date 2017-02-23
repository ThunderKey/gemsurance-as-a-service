Rails.application.routes.draw do
  root 'static#main'

  resources :resources
  resources :gems, only: [:index, :show] do
    resources :versions, controller: :gem_versions, only: [:show]
  end
end
