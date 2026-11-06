require "net/http"
require "json"

class CoinMarketCapService
  BASE_URL = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest"

  def initialize
    @api_key = Rails.application.credentials.dig(:coinmarketcap, :api_key) || ENV["CMC_PRO_API_KEY"]
  end

  def refresh_prices!
    # Strip spaces and remove any blank coin symbols safely
    symbols = Coin.pluck(:symbol).uniq.compact.map { |s| s.strip.upcase }.reject(&:empty?)
    return false if symbols.empty?

    uri = URI.parse(BASE_URL)
    uri.query = URI.encode_www_form(symbol: symbols.join(","), convert: "USD")
    
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/json"
    request["X-CMC_PRO_API_KEY"] = @api_key

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.code == "200"
      payload = JSON.parse(response.body)
      update_coins(payload["data"])
    else
      # If a ticker is invalid or missing, this logs the exact raw API message to your terminal logs
      Rails.logger.error("CoinMarketCap API Failure [HTTP #{response.code}]: #{response.body}")
      false
    end
  rescue => e
    Rails.logger.error("CoinMarketCap Service Error: #{e.message}")
    false
  end

  private

  def update_coins(data)
    data.each do |symbol, details|
      # Look up the coin by symbol case-insensitively
      coin = Coin.find_by("upper(symbol) = ?", symbol.upcase)
      next unless coin

      usd_quote = details.dig("quote", "USD")
      next unless usd_quote

      coin.update!(
        name: details["name"],
        price: usd_quote["price"],
        percent_change_1h: usd_quote["percent_change_1h"],
        percent_change_24h: usd_quote["percent_change_24h"],
        percent_change_7d: usd_quote["percent_change_7d"],
        market_cap: usd_quote["market_cap"],
        volume_24h: usd_quote["volume_24h"]
      )
    end
    true
  end
end
