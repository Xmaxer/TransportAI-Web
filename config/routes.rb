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
#  post 'requests/update_car_location'
#  post 'requests/confirm_order'
  match 'requests/ardra', via: [:get, :post]
  #post 'requests/ardra'
  get 'requests/calculate_price'
  match '/403', to: 'errors#forbidden', via: :all
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  get 'dashboard/cars', to: 'dashboard#cars'
  post 'dashboard/submit_car'
  get '/tos', to: 'static_pages#tos'
  get '/privacy_policy', to: 'static_pages#privacy_policy'
  get '/dashboard/payments', to: 'dashboard#payments'
  get 'dashboard/routes', to: 'dashboard#routes'
  get 'dashboard/settings', to: 'dashboard#settings'
  post 'dashboard/new_setting'
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
