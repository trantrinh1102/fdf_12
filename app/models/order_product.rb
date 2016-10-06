class OrderProduct < ApplicationRecord
  acts_as_paranoid
  belongs_to :user
  belongs_to :order
  belongs_to :product
  belongs_to :coupon

  enum status: {pending: 0, accepted: 1, rejected: 2}
  delegate :name, to: :user, prefix: true, allow_nil: true
  delegate :name, to: :product, prefix: true

  has_many :events , as: :eventable
  after_update_commit :send_notification


  def total_price
    product.price * quantity
  end

  scope :by_user, -> user {where user: user}
  scope :group_product, -> do
    joins(:product)
      .select("order_products.product_id, sum(order_products.quantity) as total")
      .group("order_products.product_id")
      .order("total DESC")
  end

  def send_notification
     Event.create message: self.status, user_id: user_id,
       eventable_id: id, eventable_type: OrderProduct.name
       binding.pry

  end
end
