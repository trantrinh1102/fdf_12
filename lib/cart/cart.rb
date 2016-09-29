class Cart
  attr_reader :items

  class << self
    def build_from_hash hash
      items = if hash
        hash["items"].map do |item_data|
          CartItem.new item_data["product_id"], item_data["shop_id"], item_data["quantity"]
        end
      else
        Array.new
      end
      new items
    end
  end

  def initialize items = []
    @items = items
  end

  def add_item product_id, shop_id
    item = @items.find{|item| item.product_id == product_id}
    if item
      item.increment
    else
      @items << CartItem.new(product_id, shop_id)
    end
  end

  def find_item product_id
    @items.find{|item| item.product_id == product_id}
  end

  def empty?
    @items.empty?
  end

  def count
    @items.length
  end

  def sort
    items = @items.map do |item|
      {product_id: item.product_id, quantity: item.quantity, shop_id: item.product.shop.id}
    end
    {items: items}
  end

  def total_price
    @items.inject(0){|sum, item| sum + item.total_price}
  end
end
