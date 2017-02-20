Rails.application.routes.draw do
  root 'static#main'

  resources :resources
end
