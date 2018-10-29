Rails.application.routes.draw do
  get 'errors/forbidden'
  get 'errors/not_found'
  get 'errors/internal_server_error'
  get '/new_admin', to: 'users#new'
  get '/dashboard', to: 'dashboard#index'
  get '/dashboard/reviews', to: 'dashboard#reviews'
  post '/login', to: 'sessions#create'
  post '/new_admin', to: 'users#create'
  root 'static_pages#login'
  get '/login', to: 'static_pages#login'
  get 'error', to: 'static_pages#error'
  delete '/logout',  to: 'sessions#destroy'
  get 'braintree/client_token'
  post 'braintree/checkout'
  post 'requests/update_car_location'
  match '/403', to: 'errors#forbidden', via: :all
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
