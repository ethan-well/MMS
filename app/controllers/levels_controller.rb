class LevelsController < ApplicationController
  def index
    @levels = Level.all
  end

  def edit
    @level = Level.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def update
    @level = Level.find(params[:id])
    @level.update_attributes(params.require(:level).permit(:price))

    redirect_to action: 'index'
  end
end
