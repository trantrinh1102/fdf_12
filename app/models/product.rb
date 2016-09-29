class Product < ApplicationRecord
  acts_as_paranoid
  acts_as_taggable

  belongs_to :category
  belongs_to :shop
  belongs_to :user

  has_many :order_products
  has_many :reviews, as: :reviewable
  has_many :comments, as: :commentable

  enum status: {active: 0, inactive: 1}
  mount_uploader :image, ProductImageUploader
  validates :name, presence: true, length: {maximum: 50}
  validates :description, presence: true
  validate :image_size

  delegate :name, to: :shop, prefix: :shop, allow_nil: true
  delegate :avatar, to: :shop, prefix: :shop

  scope :by_date_newest, ->{order created_at: :desc}
  scope :by_active, ->{(where status: :active)}
  scope :top_products, -> do
    by_active.by_date_newest.limit Settings.index.max_shops
  end
  private
  def image_size
    max_size = Settings.pictures.max_size
    if image.size > max_size.megabytes
      errors.add(:image, I18n.t("pictures.error_message", max_size: max_size))
    end
  end
end
