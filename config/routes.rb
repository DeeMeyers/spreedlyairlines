Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "home#index"
  get "/transactions", to: "home#transactions"
  get "/home", to: "home#index"
  get "/flights/:id", to: "home#show"
  post "/flights/:id/purchase", to: "home#purchase"
end
