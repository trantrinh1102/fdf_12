Rails.application.routes.draw do

  devise_for :admins, path: "admin",
    controllers: {sessions: "admin/sessions"}
  devise_for :users

  root "static_pages#home"
  namespace :admin do
    root "home#index"
    resources :orders, only: [:index, :show, :destroy]
    resources :shop_requests, only: [:index, :update]
    resources :categories
    resources :users
    resources :shops, except: [:new, :create, :show]
  end

  namespace :dashboard do
    root "shops#index", path: "/"
    resources :shops do
      resources :products
      resources :orders
    end
  end

  resources :shops, only: [:index, :show]
  resources :products, only: [:index, :show] do
    resources :comments, only: :create
  end
  resources :comments, only: :destroy
  resources :carts
  resources :orders
  resources :users, only: :show
  resources :categories do
    resources :products
  end
  resources :tags, only: :show
end
