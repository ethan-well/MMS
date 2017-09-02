module OrdersHelper
  def current_status_order?(status)
    params[:status] == status ? 'link_active' : ''
  end
end
