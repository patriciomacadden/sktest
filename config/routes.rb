Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  root "posts#index"

  resource :registration, only: %i[new create]

  resources :posts do
    resource :vote, only: %i[create destroy], module: :posts
    resources :comments, only: :create
  end

  resources :comments, only: %i[edit update destroy] do
    resource :vote, only: %i[create destroy], module: :comments
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
