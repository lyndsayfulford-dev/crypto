class AddUserToCoins < ActiveRecord::Migration[8.1]
  def change
    add_reference :coins, :user, null: false, foreign_key: true
  end
end
