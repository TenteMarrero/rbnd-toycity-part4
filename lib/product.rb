require_relative 'udacidata'

class Product < Udacidata
  @@headers_sym = [:id, :brand, :name, :price]
  attr_reader :id, :price, :brand, :name

  def initialize(opts={})
    # Get last ID from the database if ID exists
    get_last_id
    # Set the ID if it was passed in, otherwise use last existing ID
    @id = opts[:id] ? opts[:id].to_i : @@count_class_instances
    # Increment ID by 1
    auto_increment if !opts[:id]
    # Set the brand, name, and price normally
    @brand = opts[:brand]
    @name = opts[:name] || opts[:product]
    @price = opts[:price]
  end

  def self.get_attr_in_csv_order
    @@headers_sym
  end

  def get_attr_in_csv_order
    @@headers_sym
  end

  def self.destroy(id)
    result = destroy_element(id)
    if result
      return result
    else
      raise ProductNotFoundError, "Product with id #{id} does not exist."
    end
  end

  def self.find(id)
    result = find_attribute_value(:id, id)
    if result
      return result
    else
      raise ProductNotFoundError, "Product with id #{id} does not exist."
    end
  end

  private

    # Reads the last line of the data file, and gets the id if one exists
    # If it exists, increment and use this value
    # Otherwise, use 0 as starting ID number
    def get_last_id
      file = File.dirname(__FILE__) + "/../data/data.csv"
      last_id = File.exist?(file) ? CSV.read(file).last[0].to_i + 1 : nil
      @@count_class_instances = last_id || 0
    end

    def auto_increment
      @@count_class_instances += 1
    end

end
