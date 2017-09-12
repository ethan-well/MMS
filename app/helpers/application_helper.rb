module ApplicationHelper
  def current_menu(controller)
    controller ==  controller_name ? 'active' : ''
  end

  def current_goods(id)
    id.to_s == params['id'] ? 'active' : ''
  end

  def content_header
    case controller_name
    when 'orders'
      case action_name
      when 'purchase_history'
        '消费记录'
      when 'new'
        '业务购买'
      else
        '订单查询'
      end
    when 'infos'
      '个人中心'
    when 'admins'
      '管理后台'
    when 'special_prices'
      '特价信息'
    when 'goods'
      '业务购买'
    end
  end

  def custom_query_time(start_time, stop_time)
    if start_time.blank? && stop_time.blank?
      '未指定时间'
    elsif start_time.blank?
      "#{start_time}往后"
    elsif stop_time.blank?
      "截止#{stop_time}"
    else
      "#{start_time} —— #{stop_time}"
    end
  end

  def order_controller_action(action)
    controller_name == 'orders' && action_name == action ? 'active' : ''
  end

  def order_controller_action_goods(goods_id)
    goods_id == params['goods_id'].to_i ? 'active' : ''
  end
end
