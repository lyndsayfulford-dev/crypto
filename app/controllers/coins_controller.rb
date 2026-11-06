class CoinsController < ApplicationController
  before_action :set_coin, only: [:edit, :update, :destroy]

  def new
    @coin = Coin.new
  end

  def create
    @coin = Coin.new(coin_params)
    # Defaulting live quote statistics to zero until API refresh hits them
    @coin.price ||= @coin.cost_per_coin
    @coin.percent_change_1h = 0
    @coin.percent_change_24h = 0
    @coin.percent_change_7d = 0
    @coin.market_cap = 0
    @coin.volume_24h = 0

    if @coin.save
      redirect_to root_path, notice: "#{@coin.name} successfully added to portfolio!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @coin.update(coin_params)
      redirect_to root_path, notice: "#{@coin.name} asset records updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @coin.destroy
    redirect_to root_path, notice: "Asset removed from holdings portfolio index records."
  end

  private

  def set_coin
    @coin = Coin.find(params[:id])
  end

  def coin_params
    params.require(:coin).permit(:name, :symbol, :amount_owned, :cost_per_coin)
  end
end
