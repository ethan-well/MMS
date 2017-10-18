ActiveAdmin.register SpecialPrice do
  permit_params :price, :remark, :user_id, :goods_id
end
