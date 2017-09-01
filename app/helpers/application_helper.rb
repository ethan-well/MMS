module ApplicationHelper
  def current_menu(controller)
    controller ==  controller_name ? 'active' : ''
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
    end
  end
end
