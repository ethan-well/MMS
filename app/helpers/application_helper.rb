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
      '订单中心'
    when 'infos'
      '信息管理'
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

end
