class Settings < Settingslogic
  source "#{Rails.root}/config/order.yml"
  namespace Rails.env
end
