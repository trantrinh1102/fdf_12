class StaticPagesController < ApplicationController

  def home
    @shops = Shop.top_shops.decorate
    @products = Product.top_products
    @catogories = Category.all
    @tags = ActsAsTaggableOn::Tag.all
  end
end
