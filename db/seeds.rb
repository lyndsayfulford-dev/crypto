# Clear out any existing coins so you start fresh every time you run the seed script
puts "Cleaning up old data..."
Coin.destroy_all

puts "Creating test crypto portfolio items..."

# Bitcoin example: high precision ownership fractions
Coin.create!(
  name: "Bitcoin",
  symbol: "BTC",
  amount_owned: 0.04257134,
  cost_per_coin: 62450.00,
  price: 68120.50,
  percent_change_1h: 0.25,
  percent_change_24h: 3.45,
  percent_change_7d: -1.20,
  market_cap: 1340000000000.00,
  volume_24h: 28500000000.00
)

# Ethereum example
Coin.create!(
  name: "Ethereum",
  symbol: "ETH",
  amount_owned: 1.50000000,
  cost_per_coin: 2800.00,
  price: 2540.25,
  percent_change_1h: -0.12,
  percent_change_24h: -2.10,
  percent_change_7d: 5.80,
  market_cap: 305000000000.00,
  volume_24h: 14200000000.00
)

# A low-cost token to test precision limits
Coin.create!(
  name: "Cardano",
  symbol: "ADA",
  amount_owned: 1250.00000000,
  cost_per_coin: 0.45,
  price: 0.38521470,
  percent_change_1h: 1.10,
  percent_change_24h: 8.75,
  percent_change_7d: 12.30,
  market_cap: 13700000000.00,
  volume_24h: 450000000.00
)

puts "Seeds created successfully! Tracked #{Coin.count} coins."
