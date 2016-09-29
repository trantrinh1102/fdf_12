class ProductsController < ApplicationController
  def index
    @products = Product.active.page(params[:page])
      .per Settings.common.products_per_page
  end

  def new
    @product = Product.new
  end

  def show
    @product = Product.find_by id: params[:id]
    if @product
      @comment = @product.comments.build
      @comments = @product.comments.newest.includes :user
    else
      flash[:danger] = t "product.not_product"
      redirect_to products_path
    end
  end
end
