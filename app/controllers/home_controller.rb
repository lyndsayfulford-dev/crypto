class HomeController < ApplicationController
  # 🟢 Allow logged-out guests to see the market overview index page
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    # If the user is already logged in, seamlessly skip the landing page 
    # and take them directly to their private portfolio dashboard
    if user_signed_in?
      redirect_to coins_path
    end
  end
end
