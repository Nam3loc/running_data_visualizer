Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "dashboard#index"

  # Session routes
  post "login", to: "sessions#create", as: :session
  delete "logout", to: "sessions#destroy"

  # Fitbit OAuth routes
  get "auth/fitbit", to: "fitbit_auth#new"
  get "auth/fitbit/callback", to: "fitbit_auth#callback"
  get "auth/fitbit/failure", to: "fitbit_auth#failure"

  # Dashboard route
  get "dashboard", to: "dashboard#index"

  # API routes
  namespace :api do
    get "data", to: "data#index"
    namespace :fitbit do
      get "data/steps", to: "data#steps"
      get "data/heart_rate", to: "data#heart_rate"
      get "data/sleep", to: "data#sleep"
    end
  end

  resources :dashboard, only: [ :index ]
end
