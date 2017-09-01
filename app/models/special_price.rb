class SpecialPrice < ApplicationRecord
  belongs_to :user
  belongs_to :goods
end
