class Goods < ApplicationRecord
  # serialize :price, Array
  validates :name, presence: true, uniqueness: true
  validates :price, presence: true


  has_many :orders
  has_many :special_prices

  def self.seed
    goods_arr = ['赞', '粉丝', '鲜花']
    goods_arr.each do |good|
      Goods.create(name: good, price: [10, 20, 30])
    end
  end

  def get_current_price(level)
    price.split(' ')[ level - 1 ]
  end
end
