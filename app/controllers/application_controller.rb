class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :create_cart
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update) do |user_params|
      user_params.permit :name, :email, :chatwork_id, :avatar, :description,
        :password, :password_confirmation, :current_password
    end
  end

  private
  def create_cart
    @cart = Cart.build_from_hash session[:cart]
    @cart_group = @cart.items.group_by(&:shop_id).map  do |q|
      {shop_id: q.first, items: q.second.each.map { |qn| qn }}
    end
  end
end
