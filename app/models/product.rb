class Product < ApplicationRecord
  acts_as_paranoid
  acts_as_taggable

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  def slug_candidates
    [:name, [:name, :id]]
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end

  belongs_to :category
  belongs_to :shop
  belongs_to :user

  has_many :order_products
  has_many :reviews, as: :reviewable
  has_many :comments, as: :commentable
  has_many :events, as: :eventable

  enum status: {active: 0, inactive: 1}
  mount_uploader :image, ProductImageUploader
  validates :name, presence: true, length: {maximum: 50}
  validates :description, presence: true
  validate :image_size
  validate :start_hour_before_end_hour

  delegate :name, to: :shop, prefix: :shop, allow_nil: true
  delegate :avatar, to: :shop, prefix: :shop

  scope :by_date_newest, ->{order created_at: :desc}
  scope :by_active, ->{where status: :active}
  scope :top_products, -> do
    by_active.by_date_newest.limit Settings.index.max_products
  end

  def check_time_btn_add_cart?
    time = Time.now.strftime(Settings.time_format)
    time < start_hour.strftime(Settings.time_format) || time > end_hour.strftime(Settings.time_format)
  end

  private
  def image_size
    max_size = Settings.pictures.max_size
    if image.size > max_size.megabytes
      errors.add :image, I18n.t("pictures.error_message", max_size: max_size)
    end
  end

  def start_hour_before_end_hour
    if start_hour > end_hour
      errors.add :start_hour, I18n.t("error_message_time")
    end
  end
end
