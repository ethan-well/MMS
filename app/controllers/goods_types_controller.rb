class GoodsTypesController < ApplicationController
  def index
    @types = GoodsType.all
  end

  def destroy
    type = GoodsType.find_by_id(params[:id])
    return redirect_to :back, alert: '无法删除' if Goods.exists?(goods_type_id: params[:id])
    type.destroy
    redirect_to :back, notice: '删除成功'
  end

  def new
    @type = GoodsType.new
    respond_to do |format|
      format.js
    end
  end

  def create
    type = GoodsType.find_by_name(params[:name])
    return redirect_to :back, alert: '分类已经存在' if type.present?
    GoodsType.create(name: params[:name])
    redirect_to :back, notice: '创建成功'
  end

  def edit
    @type = GoodsType.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def update
    begin
      @type = GoodsType.find_by_id(params[:id])
      raise '分类信息不存在' if @type.nil?

      exit_type = GoodsType.find_by_name(params[:name])
      raise '分类已经存在'  if exit_type.present? && exit_type.id != @type.id

      @type.update_attribute(:name, params[:name])
      return redirect_to :back, notice: '编辑成功'
    rescue => ex
      return redirect_to :back, alert: ex.message
    end
  end

end
