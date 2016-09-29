class Dashboard::ShopsController < BaseDashboardController
  before_action :load_shop, only: [:show, :edit, :update]

  def new
    @shop = current_user.own_shops.build
  end

  def create
    @shop = current_user.own_shops.build shop_params
    if @shop.save
      flash[:success] = t "flash.success.dashboard.created_shop"
      redirect_to shops_path
    else
      flash[:danger] = t "flash.danger.dashboard.created_shop"
      render :new
    end
  end

  def show
    @shop = @shop.decorate
    @products = @shop.products.page(params[:page])
      .per Settings.common.products_per_page
  end

  def index
    @shops = current_user.own_shops.page(params[:page])
      .per(Settings.common.per_page).decorate
  end

  def edit
  end

  def update
    if @shop.update_attributes shop_params
      flash[:success] = t "flash.success.dashboard.updated_shop"
      redirect_to dashboard_shop_path(@shop)
    else
      flash[:danger] = t "flash.danger.dashboard.updated_shop"
      render :edit
    end
  end

  private
  def shop_params
    params.require(:shop).permit :id, :name, :description,
      :cover_image, :avatar
  end

  def load_shop
    @shop = current_user.own_shops.find_by id: params[:id]
    unless @shop
      flash[:danger] = t "flash.danger.load_shop"
      redirect_to :back
    end
  end
end
