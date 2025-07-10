Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      resources :pets
    end
  end

  # Secure Sidekiq Web in production
  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(username, ENV['SIDEKIQ_USERNAME']) &&
      ActiveSupport::SecurityUtils.secure_compare(password, ENV['SIDEKIQ_PASSWORD'])
    end
  end

  mount Sidekiq::Web => '/sidekiq'

  # Defines the root path route ("/")
  # root "posts#index"
end
