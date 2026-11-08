class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :coins, dependent: :destroy

  def total_portfolio_value
    coins.sum { |c| c.amount_owned.to_f * c.price.to_f }
  end
end
