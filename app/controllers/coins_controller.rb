class CoinsController < ApplicationController
  before_action :authenticate_user!

  def refresh_prices
    @coins = current_user.coins
    
    if @coins.any?
      # 1. Gather all of this user's unique crypto symbols as an uppercase string (e.g. "BTC,ETH")
      symbols_query = @coins.map { |c| c.symbol.upcase }.uniq.join(',')
      
      begin
        require 'net/http'
        require 'json'
        require 'uri'

        # 2. Build the CoinMarketCap latest quotes endpoint URI
        uri = URI("https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest")
        uri.query = URI.encode_www_form(symbol: symbols_query, convert: "USD")

        # 3. Mount the request payload and pass your Developer API authorization headers
        request = Net::HTTP::Get.new(uri.request_uri)        
        request["Accept"] = "application/json"
        
        # ⚠️ PASTE YOUR ACTUAL COINMARKETCAP DEVELOPER API KEY STRING HERE:
        request["X-CMC_PRO_API_KEY"] = "1a383f21bb874a13af34bfe1b78eed73"

        # 4. Fire the network request over secure SSL
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        if response.is_a?(Net::HTTPSuccess)
          payload = JSON.parse(response.body)
          
          # Use dig to prevent nil crashing if the key is missing
          market_data = payload["data"]

          if market_data.nil?
            # Captures any error message CoinMarketCap sent back inside the valid response body
            error_message = payload.dig("status", "error_message") || "Unknown API data mapping anomaly."
            flash[:alert] = "CoinMarketCap Data Error: #{error_message}"
          else
            # 5. Sweep through the database records securely
            @coins.each do |coin|
              ticker_key = coin.symbol.upcase
              ticker_data = market_data[ticker_key]
              
              # Fallback wrapper if the tracker returns single arrays or nested structures
              live_ticker = ticker_data.is_a?(Array) ? ticker_data.first : ticker_data

              if live_ticker
                usd_quote = live_ticker.dig("quote", "USD")
                
                if usd_quote
                  coin.update(
                    price: usd_quote["price"],
                    market_cap: usd_quote["market_cap"],
                    percent_change_1h: usd_quote["percent_change_1h"],
                    percent_change_24h: usd_quote["percent_change_24h"]
                  )
                end
              end
            end 
            
            flash[:notice] = "Market rates successfully synchronised with live CoinMarketCap ledgers!"
          end
        else
          flash[:alert] = "CoinMarketCap API Error: #{response.code} - Check your API key layout."
        end # <--- Removed the duplicate outer 'if' block container

      rescue => e
        flash[:alert] = "Network transmission timeout: #{e.message}"
      end
    else
      flash[:notice] = "No tracked assets present to refresh."
    end

    # Redirect directly back to your clean portfolio index container view
    redirect_to coins_path
  end





  # 1. GET /coins (Your beautiful new dashboard index)
  def index
    @coins = current_user.coins.order(:name)
    
    # Total Capital Contributed (Acquisition Cost Basis)
    @total_cost_basis = @coins.sum { |coin| coin.amount_owned.to_f * coin.cost_per_coin.to_f }
    
    # Total Current Valuation (Live Price * Quantity)
    @total_current_value = @coins.sum { |coin| coin.amount_owned.to_f * (coin.price.to_f || 0.0) }
    
    # Aggregate Profit / Loss
    @total_profit_loss = @total_current_value - @total_cost_basis
    
    # Total Percentage Gain/Loss
    @total_percentage_change = @total_cost_basis > 0 ? (@total_profit_loss / @total_cost_basis) * 100 : 0

    # Calculate portfolio distribution allocations for Chart.js
    @portfolio_distribution = @coins.map do |coin|
      current_value = coin.amount_owned.to_f * (coin.price.to_f || 0.0)
      percentage = @total_current_value > 0 ? (current_value / @total_current_value) * 100 : 0
      
      {
        name: coin.name,
        symbol: coin.symbol.upcase,
        current_value: current_value,
        percentage: percentage
      }
    end.sort_by { |asset| -asset[:percentage] } # Order by largest holding first
  end

  # 2. GET /coins/new
  def new
    @coin = current_user.coins.build
  end

  # 3. POST /coins
  def create
    @coin = current_user.coins.build(coin_params)

    if @coin.save
      redirect_to coins_path, notice: "Asset successfully committed to ledger!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # 4. GET /coins/:id/edit
  def edit
  @coin = Coin.find(params[:id]) 
  end

  # 5. PATCH/PUT /coins/:id
    # 5. PATCH/PUT /coins/:id
  def update
    @coin = Coin.find(params[:id]) # <--- ADD THIS LINE HERE
    
    if @coin.update(coin_params)
      redirect_to coins_path, notice: "Asset was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    @coin = Coin.find(params[:id]) # <--- ADD THIS LINE HERE
    @coin.destroy
    redirect_to coins_path, notice: "Asset removed from holdings portfolio index records."
  end

  private

  # Strong parameters block malicious data injection
  def coin_params
    params.require(:coin).permit(:name, :symbol, :amount_owned, :cost_per_coin)
  end

  # Security checkpoint: Scopes the lookup directly to the logged-in user
  def set_coin
    @coin = current_user.coins.find(params[:id])
  end
end
