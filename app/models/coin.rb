class Coin < ApplicationRecord
  validates :name, presence: true
  validates :symbol, presence: true, length: { maximum: 10 }
  validates :amount_owned, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :cost_per_coin, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
