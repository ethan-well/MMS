module InfosHelper
  def current_price(level_id)
    level_id == current_user.level_id ?  "bg-aqua" : ''
  end
end
