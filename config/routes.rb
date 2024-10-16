Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  concern :api_endpoints do
    mount_devise_token_auth_for 'User', at: 'auth', controllers: {
      passwords: 'api/v1/passwords',
      sessions: 'api/v1/sessions',
      registrations: 'api/v1/registrations',
    },
    defaults: { format: :json }
  end

  namespace :api do
    namespace :v1 do

      resources :users, only: [:create, :update] do
        collection do
          get :me
        end
      end

      resources :products, only: [:index] do
        collection do
          get :product_detail
        end
      end
      concerns :api_endpoints
    end
  end
  # Defines the root path route ("/")
  # root "posts#index"
end
