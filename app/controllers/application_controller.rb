class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(:name, :email, :h_invitation_code, :password, :password_confirmation)
    end
  end

  private
  def not_authenticated
    redirect_to login_path, alert: "Please login first"
  end

  def is_admin?
    unless current_user.admin
      redirect_to :back, alert: '抱歉，权限不够！'
    end
  end
end
