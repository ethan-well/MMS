ActiveAdmin.register RechargeRecord do
  permit_params :amount, :user_id, :number, :pay_type
end
