Rails.application.routes.draw do
  get "coins/new"
  get "coins/create"
  get "coins/edit"
  get "coins/update"
  get "coins/destroy"
  root "home#index"
  post "refresh_prices", to: "home#refresh", as: :refresh_prices
  resources :coins # Prepping routing pathways for Part 2 forms!
end
