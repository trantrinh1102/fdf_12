class Dashboard::ProductsController < BaseDashboardController
  before_action :load_shop
  before_action :load_categories, only: [:edit, :new, :update]
  before_action :load_product, only: [:edit, :update, :destroy]
  before_action :load_products, only: :index

  def new
    @product = @shop.products.new
  end

  def index
    @products.page(params[:page]).per Settings.common.products_per_page
  end

  def edit
  end

  def create
    @product = @shop.products.new product_params
    if @product.save
      flash[:success] = t "flash.success.dashboard.create_product"
      redirect_to dashboard_shop_path @shop
    else
      flash[:danger] = t "flash.danger.dashboard.create_product"
      render :new
    end
  end

  def update
    if @product.update_attributes product_params
      flash[:success] = t "flash.success.dashboard.edit_product"
      respond_to do |format|
        format.json do
          render json: {status: @product.status}
        end
        format.html {redirect_to dashboard_shop_path @shop}
      end
    else
      flash[:danger] = t "flash.danger.dashboard.edit_product"
      render :edit
    end
  end

  def destroy
    if @product.order_products.any?
      flash[:danger] = t "flash.danger.dashboard.order_product"
    elsif @product.destroy
      flash[:success] = t "flash.success.dashboard.delete_product"
    else
      flash[:danger] = t "flash.danger.dashboard.delete_product"
    end
    redirect_to dashboard_shop_path @shop
  end

  private
  def load_shop
    @shop = Shop.find_by id: params[:shop_id]
    unless @shop
      flash[:danger] = t "flash.danger.dashboard.shop.not_found"
      redirect_to dashboard_shops_path
    end
  end

  def product_params
    params.require(:product).permit :id, :name, :description, :price,
      :category_id, :user_id, :image, :status, :tag_list
  end

  def load_categories
    @categories = Category.all
  end

  def load_product
    @product = @shop.products.find_by id: params[:id]
    unless @product
      flash[:danger] = t "flash.danger.dashboard.product.not_found"
      redirect_to dashboard_shop_products_path
    end
  end

  def load_products
    @products = @shop.products
  end
end
