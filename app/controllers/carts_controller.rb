class CartsController < ApplicationController
  before_action :load_product, only: :update

  def index
  end

  def update
    @cart.add_item params[:id], @product.shop.id
    session["cart"] = @cart.sort
  end

  def edit
    item = @cart.find_item params[:id]
    if item.quantity > 1
      item.decrement
      session["cart"] = @cart.sort
    end
    respond_to do |format|
      format.js {render :update}
    end
  end

  def destroy
    cart = session["cart"]
    item = cart["items"].find{|item| item["product_id"] == params[:id]}
    if item
      cart["items"].delete item
      create_cart
    end
    respond_to do |format|
      format.js {render :update}
    end
  end

  private
  def load_product
    @product = Product.find_by id: params[:id]
    unless @product
      flash[:danger] = t "flash.danger.load_product"
      redirect_to root_path
    end
  end
end
