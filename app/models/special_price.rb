class SpecialPrice < ApplicationRecord
  belongs_to :user
  belongs_to :goods

  def self.seed
    SpecialPrice.create(user_id: 28, goods_id: 3, price: 15, remark: 'HAHAHHAHA')
  end
end
