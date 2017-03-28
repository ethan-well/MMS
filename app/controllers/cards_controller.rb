class CardsController < ApplicationController
  layout 'card'
  def index
    @cards = Card.all()
  end

  def new
    @card = Card.new()
  end

  def create

  end


  def show

  end

  def update

  end

  def destroy

  end

  private
    def card_params
      params.require("card").permit(:number, :balance)
    end

end
