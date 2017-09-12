class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  layout 'session'
  before_action :can_sigin_in?, only: [:create]
  before_action :captcha_validated?, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  def captcha_validated?
    unless verify_rucaptcha?
      return redirect_to :back, alert: '验证码输入不正确'
    end
  end

  def can_sigin_in?
    user = User.find_by_email(params['user']['email'])
    unless user.active
      return redirect_to :back, alert: '目前不能登录，请联系管理员'
    end
  end
end
