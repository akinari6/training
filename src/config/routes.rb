# frozen_string_literal: true

Rails.application.routes.draw do
  resources :tasks do
    patch :complete, on: :member
    patch :reopen, on: :member
  end

  resource :session, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create]

  root "tasks#index"
end
