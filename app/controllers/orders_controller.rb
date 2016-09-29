class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_shop, except: [:edit, :update, :index]
  before_action :load_order, only: :destroy

  def index
    @orders = current_user.orders.by_date_newest.page(params[:page])
      .per(Settings.common.per_page)
  end

  def new
    @order = @shop.orders.new
    @cart_shop = load_cart_shop
  end

  def show
    @order =  Order.find_by id: params[:id]
    unless @order
      flash[:danger] = t "oder.not_oder"
      redirect_to new_order_path
    end
  end

  def create
    @cart_shop = load_cart_shop
    if @cart_shop.present?
      @order = Order.new order_params @cart_shop
      if @order.save
        cart = session["cart"]
        item = cart["items"].find{|item| item["shop_id"] == @shop.id}
        if item
          create_cart
          cart["items"].delete item
        end
        flash[:success] = t "flash.success.order"
        redirect_to order_path @order, shop_id: @shop.id
      else
        flash[:danger] = t "oder.not_oder"
        redirect_to new_order_path
      end
    else
      flash[:danger] = t "oder.not_product_in_cart"
      redirect_to carts_path
    end
  end

  def destroy
    if @order.destroy
      flash[:success] = t "oder.deleted"
    else
      flash[:danger] = t "oder.not_delete"
    end
    redirect_to orders_path
  end

  private

  def order_params cart_shop
    params.require(:order).permit(:notes)
      .merge! user: current_user, total_pay: cart_shop.total_price,
      cart: cart_shop, shop: @shop
  end

  def load_shop
    @shop = Shop.find_by id: params[:shop_id]
    unless @shop
      flash[:danger] = t "flash.danger.load_shop"
      redirect_to products_path
    end
  end

  def load_order
    @order = Order.find_by id: params[:id]
    unless @order
      flash[:danger] = t "flash.danger.load_order"
      redirect_to orders_path
    end
  end

  def load_cart_shop
    cart_shop = @cart_group.detect {|shop| shop[:shop_id] == @shop.id}
    Cart.new cart_shop[:items]
  end
end
