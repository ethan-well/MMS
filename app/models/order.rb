class Order < ApplicationRecord
  validates :count, presence: true
  validates :account, presence: true
  validates :price_current, presence: true
  validates :status, presence: true

  belongs_to :user
  belongs_to :goods

  after_create :add_identification_code

  self.per_page = 10

  def add_identification_code
    id_str = self.id.to_s
    len = 6 - id_str.length
    id_code =  self.created_at.to_i.to_s + '0'*len + id_str
    self.update_attribute(:identification_code, id_code)
  end
end
