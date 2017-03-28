class UsersController < ApplicationController
  def index
  end

  def new
    @user = User.new()
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to login_path
    else
      flash[:error] = "注册失败"
      render action: 'new'
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
