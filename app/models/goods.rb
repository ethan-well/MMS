class Goods < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :price, presence: true

  has_many: orders
end
