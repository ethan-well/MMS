ActiveAdmin.register Order do
  permit_params :count, :price_current, :total_price, :status, :account,
    :goods_id, :user_id, :identification_code, :remark, :start_num, :aims_num,
    :current_num, :level_crrent, :h_level_crrent, :h_price_current
end
