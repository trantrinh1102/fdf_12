class Dashboard::OrdersController < BaseDashboardController
  before_action :load_shop, only: [:index, :show, :update]

  def index
    if @shop
      @orders = @shop.orders.includes(:user).page(params[:page])
        .per Settings.common.per_page
    end
  end

  def show
    if @shop
      @order = @shop.orders.find_by id: params[:id]
      unless @order
        flash[:danger] = t "flash.danger.load_order"
        redirect_to dashboard_shop_orders_path
      end
    end
  end

  def update
    if @shop
      @order = @shop.orders.find_by id: params[:id]
      if @order.update_attributes order_params
        flash[:success] = t "flash.success.update"
      else
        render :back
      end
    end
  end

  private
  def order_params
    params.require(:order).permit :status
  end

  def load_shop
    @shop = Shop.find_by id: params[:shop_id]
    unless @shop
      flash[:danger] = t "flash.danger.load_shop"
      redirect_to dashboard_shops_path
    end
  end
end
