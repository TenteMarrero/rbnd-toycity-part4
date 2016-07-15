require 'faker'

# This file contains code that populates the database with
# fake data for testing purposes

def db_seed
  brands = []
  30.times do
    brands << Faker::Company.name
  end
  300.times do
    name = Faker::Commerce.product_name
    price = Faker::Commerce.price.to_f
    Product.create(brand: brands.sample, name: name, price: price)
  end
end
