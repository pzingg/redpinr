Rails.application.routes.draw do
  
  resources :maps
  root to: 'maps#index'
end
