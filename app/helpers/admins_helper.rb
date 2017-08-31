module AdminsHelper
  def show_light?(action)
    action_name == action ? 'btn-success' : 'btn-primary'
  end
end
