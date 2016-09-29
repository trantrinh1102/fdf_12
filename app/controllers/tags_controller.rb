class TagsController < ApplicationController
  def show
    @tag = ActsAsTaggableOn::Tag.find_by id: params[:id]
    unless @tag
      flash[:danger] = t "flash.danger"
      redirect_to root_path
    end
    @products = Product.active.tagged_with(@tag.name).page(params[:page])
      .per Settings.common.products_per_page
  end
end
