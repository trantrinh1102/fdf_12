class Order < ApplicationRecord
  attr_accessor :cart, :change_status
  acts_as_paranoid
  belongs_to :user
  belongs_to :shop
  belongs_to :coupon

  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products
  has_many :events , as: :eventable

  enum status: {pending: 0, open: 1, closed: 2}
  delegate :name, to: :shop, prefix: :shop
  delegate :name, to: :user, prefix: :user, allow_nil: true
  delegate :name, to: :coupon, prefix: :coupon, allow_nil: true

  after_update :build_order_products
  after_create :build_order_products
  after_create_commit :send_notification
  after_create :check_new_order

  scope :by_date_newest, ->{order created_at: :desc}

  ransacker :created_at do
    Arel.sql("date(created_at)")
  end

  scope :between_date, -> begin_date, end_date do
    where(created_at: begin_date..end_date).
      group_year.group_month.group_day
  end

  scope :group_day_this_week, -> do
    where(created_at: Time.now.beginning_of_week..Time.now.end_of_week).
      group_month.group_day
  end

  scope :group_week_this_month, -> do
    where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).
      group_month.group "EXTRACT(week FROM created_at)"
  end

  scope :group_month_this_year, -> do
    where(created_at: Time.now.beginning_of_year..Time.now.end_of_year).
      group_year.group_month
  end

  scope :group_year , -> {group "EXTRACT(year FROM created_at)"}
  scope :group_month, -> {group "EXTRACT(month FROM created_at)"}
  scope :group_day, -> {group "EXTRACT(day FROM created_at)"}

  def build_order_products
    unless self.change_status
      cart.items.each do |item|
        order_products.create product_id: item.product_id,
          quantity: item.quantity, user_id: user_id
      end
    end
  end

  class << self
    def build_data_chart user_shops, category_statistic
      order_chart = case category_statistic
      when "current_week"
        map_hash user_shops, :group_day_this_week
      when "current_month"
        map_hash user_shops, :group_week_this_month
      when "current_year"
        map_hash user_shops, :group_month_this_year
      when "year"
        map_hash user_shops, :group_year
      else
        map_hash user_shops, :group_day_this_week
      end
    end

    def build_data_between_date user_shops, begin_date, end_date
      user_shops.map do |shop|
        {name: shop.name, data: shop.orders.
          between_date(begin_date, end_date).count}
      end
    end

    def map_hash user_shops, method_send
      user_shops.map do |shop|
        {name: shop.name, data: shop.orders.send(method_send).count}
      end
    end
  end

  def total_price
    order_products.inject(0){|sum, item| sum + item.total_price}
  end

  def total_pay_user user
    order_products.by_user(user)
      .inject(0){|sum, item| sum + item.total_price}
  end

  def total_price_accepted
    order_products.accepted
      .inject(0){|sum, item| sum + item.total_price}
  end

  def send_notification
    Event.create message: "",
      user_id: self.shop.owner_id, eventable_id: id, eventable_type: Order.name
  end

  def update_status_new_order
    if self.pending?
      self.update_attributes(status: :closed, change_status: true)
      send_notification_orderer
    end
  end

  def send_notification_orderer
    Event.create message: :closed,
      user_id: user_id, eventable_id: id, eventable_type: Order.name
  end
  private
  def check_new_order
    delay(run_at: Settings.delay_check_order.minutes.from_now)
      .update_status_new_order
  end
end
