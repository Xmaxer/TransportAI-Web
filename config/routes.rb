Rails.application.routes.draw do
  get 'dashboard/index'
  root 'static_pages#home'
  get 'static_pages/login'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
