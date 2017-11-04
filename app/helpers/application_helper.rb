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

  def current_goods_type(type_id)
    if controller_name == 'orders' && action_name == 'new'
      Goods.find(params[:goods_id]).goods_type_id == type_id ? 'active' : ''
    end
  end

  def user_level_info
    current_level = Level.find_by_id(current_user.level_id)
    total_spend = current_user.total_spend
    if current_user.level_id < 4
      last_leve_price = Level.find_by_id(current_user.level_id + 1).price
      info = %Q(
                  级别：[<span class="level-info"> LV#{current_user.level_id} </span>]
                  距[LV#{current_user.level_id + 1}]差：[<span class="level-info">#{last_leve_price - total_spend}</span>]元
                )
    else
      info = %Q(级别：[<span class="level-info"> LV#{current_user.level_id} </span>])
    end

    return info
  end

  def get_on_used_notice(system_price, special_price)
    special_price.present? && special_price < system_price ? '不能低于系统价格，请重新填写' : ''
  end
end
