Rails.application.routes.draw do
  post 'signup' => 'accounts#signup'
  post 'login' => 'accounts#login'
  post 'logout' => 'accounts#logout'

  resources :users
  resources :purchases
  resources :albums
end
