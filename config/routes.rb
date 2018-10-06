Rails.application.routes.draw do
  get '/new_admin', to: 'users#new'
  get '/dashboard', to: 'dashboard#index'
  post '/login', to: 'sessions#create'
  root 'static_pages#home'
  get '/login', to: 'static_pages#login'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
