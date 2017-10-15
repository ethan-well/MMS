class Order < ApplicationRecord
  validates :count, presence: true
  validates :price_current, presence: true
  validates :total_price, presence: true
  validates :status, presence: true

  belongs_to :user
  belongs_to :goods

  after_create :add_identification_code

  after_update :update_user_level
  after_update :deduct_percentage

  has_one :deduct_percentages

  #生成订单编号
  def add_identification_code
    self.update_attribute(:identification_code, 100000 + id)
  end

  def is_not_pay?
    self.status == 'Waiting'
  end

  def is_paied?
    self.status == 'Paied'
  end

  def is_canceled?
    self.status == 'Canceled'
  end

  def is_finished?
    self.status == 'Finished'
  end

  def can_cancel?
    self.status == 'Waiting'
  end

  def can_make_finished?
    self.status == 'Paied'
  end

  def can_edit?
    status == 'Paied' || status == 'Waiting'
  end

  def status_in_word
    case status
    when 'Waiting'
      '等待处理'
    when 'Refund'
      '已取消，已退款'
    when 'Finished'
      '已完成'
    when 'Dealing'
      '处理中'
    when 'RefundFailed'
      '退款失败'
    end
  end

  def status_in_word_admin
    case status
    when 'Waiting'
      '等待处理'
    when 'Dealing'
      '处理中'
    when 'Finished'
      '已完成'
    when 'Refund'
      '已经退款'
    when 'RefundFailed'
      '退款失败'
    end
  end

  def update_user_level
    if status_changed? && status == 'Finished' && user.level_id < 4
      tar_user = self.user
      total_spend = tar_user.total_spend
      current_level_id = tar_user.level_id
      next_level = Level.find(current_level_id + 1)

      tar_user.update_attribute(:level_id, next_level.id) if total_spend >= next_level.price
    end
  end

  def deduct_percentage
    if status_changed? && status == 'Finished'
      user = self.user
      goods = self.goods
      h_user = user.h_user
      if h_user.present?
        price_current = self.price_current || 0
        count = self.count
        h_price_current = self.h_price_current || 0
        if (price_current - h_price_current) > 0
          deduct_percentage = count * (price_current - h_price_current)
          DeductPercentage.transaction do
            current_deduct_percentage = h_user.deduct_percentage || 0
            h_user.update_attribute(:deduct_percentage, current_deduct_percentage + deduct_percentage)
            DeductPercentage.create(user_id: h_user.id, low_user_id: user.id, order_id: self.id, deduct_percentages: deduct_percentage)
          end
        end
      end
    end
  end
end
