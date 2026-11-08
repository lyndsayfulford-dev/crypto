Rails.application.routes.draw do
  devise_for :users

  # 1. Nest the custom pricing hook cleanly inside the coins resource loop
  resources :coins, only: [:index, :new, :create, :edit, :update, :destroy] do
    collection do
      get :refresh_prices # Maps cleanly to: refresh_prices_coins_path
    end
  end

  # 2. Points your home page cleanly to your working portfolio view dashboard
  root to: "coins#index" 
end
