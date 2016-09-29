class ShopsController < ApplicationController
  before_action :load_shop, only: :show

  def index
    @shops = Shop.active.page(params[:page])
      .per(Settings.common.per_page).decorate
  end

  def show
    @products = @shop.products.active.page(params[:page])
      .per Settings.common.products_per_page
    @shop = @shop.decorate
  end

  private
  def load_shop
    @shop = Shop.find_by id: params[:id]
    unless @shop
      flash[:danger] = t "flash.danger.load_shop"
      redirect_to root_path
    end
  end
end
