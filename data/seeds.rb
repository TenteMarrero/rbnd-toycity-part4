require 'faker'

# This file contains code that populates the database with
# fake data for testing purposes

def db_seed
  brands = []
  10.times do |id|
    brand = Faker::Company.name
    name = Faker::Commerce.product_name
    price = Faker::Commerce.price.to_f
    Product.create(brand: brand, name: name, price: price)
  end
end
