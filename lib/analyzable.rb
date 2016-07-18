module Analyzable
  # Your code goes here!
  def average_price(products)
    (products.inject(0.0) { |result, product| result + product.price.to_f } / products.length.to_f).round(2)
  end
end
