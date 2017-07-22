module ApplicationHelper
  def current_menu(controller)
    controller ==  controller_name ? 'active' : ''
  end

  def content_header
    return '订单中心' if controller_name == 'orders'
    return '信息管理' if controller_name == 'users'
  end
end
