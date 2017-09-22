class NoticesController < ApplicationController
  before_action :is_admin?

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
    result = notice.update_attribute(:content, params['notice']['content'])

    redirect_to :back, notice: '编辑成功'
  end
end
