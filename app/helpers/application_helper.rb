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
        '订单中心'
      end
    when 'infos'
      case action_name
      when 'l_infos'
        '下级及提成'
      else
        '基本信息'
      end
    when 'admins'
      '管理后台'
    when 'special_prices'
      '特价信息'
    when 'goods'
      '业务购买'
    when 'recharge_records'
      '充值中心'
    when 'deduct_percentages'
      '下级及提成'
    when 'h_set_prices'
      '下级代理特价'
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

  def user_info_active
    case controller_name
    when 'infos'
      'active'
    when 'recharge_records'
      'active'
    when 'h_set_prices'
      'active'
    else
      ''
    end
  end

  def l_infos
    controller_name == 'infos' && action_name == 'l_infos' ? 'active' : ''
  end

  def current_controller_action(controller, action)
    controller_name == controller && action == action_name ? 'active' : ''
  end

  def invit_link
    #host = 'http://localhost:3000'
    host = 'http://119.29.152.254:3000'
    "#{host}/invites?invitation_code=#{current_user.invitation_code}"
  end
end
