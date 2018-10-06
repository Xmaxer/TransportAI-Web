Rails.application.routes.draw do
  get '/new_admin', to: 'users#new'
  get '/dashboard', to: 'dashboard#index'
  post '/login', to: 'sessions#create'
  root 'static_pages#home'
  get '/login', to: 'static_pages#login'
  get 'error', to: 'static_pages#error'
  delete '/logout',  to: 'sessions#destroy'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
