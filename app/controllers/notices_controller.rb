class NoticesController < ApplicationController
  before_action :is_admin?, except: [:show]

  def index
  end

  def show
    @notice = Notice.find(params[:id])
  end

  def create
    Notice.create(params.require('notice').permit('content', 'title'))
    redirect_to :back
  end

  def edit
    @notice = Notice.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def destroy
    notice = Notice.find(params['id'])
    notice.destroy
    redirect_to :back
  end

  def update
    notice = Notice.find(params['notice']['id'])
    result = notice.update_attributes(params.require(:notice).permit(:title, :content))

    redirect_to :back, notice: '编辑成功'
  end

  def alert_show
    notice = Notice.find(params[:id])
    is_alert = params[:is_alert]
    result = notice.update_attribute(:is_alert, is_alert)

    redirect_to :back
  end
end
