# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'

  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
      resource :session, only: %i[create destroy]
      get 'me', to: 'sessions#show'
    end
  end
end
