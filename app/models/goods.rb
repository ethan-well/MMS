class Goods < ApplicationRecord
  # serialize :price, Array
  validates :name, presence: true, uniqueness: true
  validates :price, presence: true

  has_many :orders
  has_many :special_prices
  has_many :h_set_prices
  belongs_to :goods_type

  class << self
    def seed
      goods_arr = ['赞', '粉丝', '鲜花']
      goods_arr.each do |good|
        Goods.create(name: good, price: [10, 20, 30])
      end
    end

    def cache_goods_sale_info
      finished_orders = Order.where('status = ?', 'Finished')
      # total_spend
      Rails.cache.fetch("all_orders_total_spend", expires_in: 12.hours) do
        finished_orders.sum(:total_price).to_f
      end
      # total_deduct_percentage =
      Rails.cache.fetch("all_orders_deduct_percentage", expires_in: 12.hours) do
        DeductPercentage.where(order_id: finished_orders.pluck(:id)).sum(:deduct_percentages).to_f
      end
      # month_ago_finished_orders
      month_ago_finished_orders =
        Rails.cache.fetch("all_orders_month_ago_finished_orders", expires_in: 12.hours) do
          finished_orders.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_month, DateTime.now).reload
        end
      # month_ago_spend
      Rails.cache.fetch("all_orders_month_ago_spend", expires_in: 12.hours) do
        month_ago_finished_orders.sum(:total_price).to_f
      end

      # month_ago_deduct_percentage
      Rails.cache.fetch("all_orders_month_ago_deduct_percentage", expires_in: 12.hours) do
        DeductPercentage.where(order_id: month_ago_finished_orders.pluck(:id)).sum(:deduct_percentages).to_f
      end

      # today_finished_orders
      today_finished_orders =
        Rails.cache.fetch("all_orders_month_today_finished_orders", expires_in: 12.hours) do
          finished_orders.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_day, DateTime.now).reload
        end

      # today_spend
      Rails.cache.fetch("all_orders_today_spend", expires_in: 12.hours) do
        today_finished_orders.sum(:total_price).to_f
      end
      # today_deduct_percentage
      Rails.cache.fetch("all_orders_today_spend", expires_in: 12.hours) do
        DeductPercentage.where(order_id: today_finished_orders.pluck(:id)).sum(:deduct_percentages).to_f
      end
    end
  end

  def cache_sale_info
    finished_orders = self.orders.where('status =?', 'Finished')
    # total_spend
    Rails.cache.fetch("goods_#{self.id}_orders_total_spend", expires_in: 12.hours) do
      finished_orders.sum(:total_price).to_f
    end

    #total_deduct_percentage =
    Rails.cache.fetch("goods_#{self.id}_orders_total_deduct_percentage", expires_in: 12.hours) do
      DeductPercentage.where(order_id: finished_orders.pluck(:id)).sum(:deduct_percentages).to_f
    end

    # smonth_ago_finished_orders
    month_ago_finished_orders =
      Rails.cache.fetch("goods_#{self.id}_orders_month_ago_finished_orders", expires_in: 12.hours) do
        finished_orders.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_month, DateTime.now).reload
      end

    # month_ago_spend
    Rails.cache.fetch("goods_#{self.id}_orders_month_ago_spend", expires_in: 12.hours) do
      month_ago_finished_orders.sum(:total_price).to_f
    end

    # month_ago_deduct_percentage
    Rails.cache.fetch("goods_#{self.id}_orders_month_ago_deduct_percentage", expires_in: 12.hours) do
      DeductPercentage.where(order_id: month_ago_finished_orders.pluck(:id)).sum(:deduct_percentages).to_f
    end

    # today_finished_orders
    today_finished_orders =
      Rails.cache.fetch("goods_#{self.id}_orders_today_finished_orders", expires_in: 12.hours) do
        finished_orders.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_day, DateTime.now).reload
      end

    # today_spend
    Rails.cache.fetch("goods_#{self.id}_orders_today_spend", expires_in: 12.hours) do
      today_finished_orders.sum(:total_price).to_f
    end

    # today_deduct_percentage
    Rails.cache.fetch("goods_#{self.id}_orders_today_deduct_percentage", expires_in: 12.hours) do
      DeductPercentage.where(order_id: today_finished_orders.pluck(:id)).sum(:deduct_percentages).to_f
    end
  end

  def get_current_price(level)
    Float(price.split(' ')[ level - 1 ])
  end
end
