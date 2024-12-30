Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  get "/players" => "players#index"
  post "/players" => "players#create"
  delete "/players/:id" => "players#destroy"

  get "/rooms" => "rooms#index"
  post "/rooms" => "rooms#create"
  post "/rooms/:id/join" => "rooms#join"
  post "/rooms/:id/leave" => "rooms#leave"
  post "/rooms/:id/start" => "rooms#start"
  post "/rooms/:id/action" => "rooms#action"
  post "/rooms/:id/next-phase" => "rooms#next_phase"
  post "/rooms/:id/end" => "rooms#end"
end
