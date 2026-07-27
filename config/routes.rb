# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'

  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
      resource :session, only: %i[create destroy]
      get 'me', to: 'sessions#show'
      resources :cat_facts, only: [:index]
      resources :likes, only: %i[create destroy]
      resources :liked_facts, only: [:index]
    end
  end
end
