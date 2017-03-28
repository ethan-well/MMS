class Card < ApplicationRecord
  has_many :leases
  has_many :users, through: :leases
end
