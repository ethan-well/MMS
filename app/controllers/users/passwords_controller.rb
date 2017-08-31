class Users::PasswordsController < Devise::PasswordsController
  layout 'resetpassword'
  before_action :captcha_validated?, only: [:create]

  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  def create
    super
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  def captcha_validated?
    unless verify_rucaptcha?
      return redirect_to :back, alert: '验证码输入不正确'
    end
  end
end
