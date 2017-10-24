class InfosController < ApplicationController
  def index
    @goods = Goods.all
    @total_spend = current_user.total_spend
    @orders_count = current_user.orders.count
    @notices = Notice.all
    @notices_alert = Notice.where(is_alert: true)
    @has_alert = Notice.exists?(is_alert: true)
  end

  def l_infos
    @l_users = current_user.low_level_users
  end

  def reset_my_password
    begin
      valid = current_user.valid_password?(params[:current_pasword])
      raise '当前密码不正确' unless valid
      raise '密码不能为空' unless params[:password].present?
      raise '两次输入密码不一致' unless params[:password] == params[:password_confirmation]
      raise '密码不能少于六位' unless params[:password].length >= 6

      current_user.password = params[:password]
      current_user.password_confirmation = params[:password_confirmation]
      current_user.md5_password = Digest::MD5.hexdigest(current_user.email + 'WoNiMaDeYa' + Time.now.to_s)
      current_user.save!

      flash[:notice] = '密码更改成功，请用新密码登录'
      return redirect_to new_user_session_path
    rescue => ex
      flash[:alert] = ex.message
    end
    redirect_to :back
  end
end
