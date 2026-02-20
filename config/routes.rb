Rails.application.routes.draw do
  get "dashboard/index"
  devise_for :users

  namespace :admin do
    resources :users, only: [ :index ] do
      member do
        patch :toggle_admin
        patch :toggle_active
      end
    end
  end

  devise_scope :user do
    authenticated :user do
      root to: "dashboard#index", as: :authenticated_root
    end

    unauthenticated do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end
  end

  get "dashboard", to: "dashboard#index", as: :dashboard
  resources :customers do
    member do
      patch :toggle_active
    end
  end
  resources :sales
  resources :payments
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
