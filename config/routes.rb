Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  scope '/api/v1', defaults: { format: :json } do
    resources :access_points
    resources :fingerprints
    resources :locations
    resources :maps
    resources :measurements
    resources :readings
  end
  
  post '/apscan', to: 'readings#apscan', as: 'apscan'
end
