class HomeController < ApplicationController
  def index
    @coins = Coin.all
    calculate_totals
  end

  def refresh
    service = CoinMarketCapService.new
    if service.refresh_prices!
      flash[:notice] = "Market rates updated successfully from CoinMarketCap!"
    else
      flash[:alert] = "Could not update rates. Checked mock defaults or your API key settings."
    end
    redirect_to root_path
  end

  private

  def calculate_totals
    @total_investment = @coins.sum { |coin| coin.amount_owned.to_f * coin.cost_per_coin.to_f }
    @current_portfolio_value = @coins.sum { |coin| coin.amount_owned.to_f * coin.price.to_f }
    @net_profit_loss = @current_portfolio_value - @total_investment
    @percentage_return = @total_investment.positive? ? (@net_profit_loss / @total_investment) * 100 : 0
  end
end
