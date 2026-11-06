class CreateCoins < ActiveRecord::Migration[8.1]
  def change
    create_table :coins do |t|
      t.string :name
      t.string :symbol
      t.decimal :amount_owned, precision: 16, scale: 8
      t.decimal :cost_per_coin, precision: 16, scale: 8
      t.decimal :price, precision: 16, scale: 8
      t.decimal :percent_change_1h, precision: 5, scale: 2
      t.decimal :percent_change_24h, precision: 5, scale: 2
      t.decimal :percent_change_7d, precision: 5, scale: 2
      t.decimal :market_cap, precision: 20, scale: 2
      t.decimal :volume_24h, precision: 20, scale: 2

      t.timestamps
    end
  end
end
