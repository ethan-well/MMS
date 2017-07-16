class Order < ApplicationRecord
  validates :count, presence: true
  validates :account, presence: true
  validates :price_current, presence: true
  validates :status, presence: true

  belongs_to :user
  belongs_to :goods
end
