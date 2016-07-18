require_relative 'find_by'
require_relative 'errors'
require 'csv'

class Udacidata
  @@data_path = File.dirname(__FILE__) + "/../data/data.csv"

  def self.create(attributes = nil)
    object = self.new(attributes)
    unless exist_row_with_id?(object.id)
      save(object.id, attributes)
    end
    return object
  end

  def self.all
    rows = CSV.read(@@data_path)
    rows.delete_at(0)
    rows.map do |row|
      create_instance_from_array(row)
    end
  end

  def self.first(item = 1)
    item > 1 ? all.take(item) : all.first
  end

  def self.last(item = 1)
    item > 1 ? all.reverse.take(item) : all.reverse.first
  end

  def self.find(id)
    result = find_attribute_value(:id, id)
    if result
      return result
    else
      raise ProductNotFoundError, "Product with id #{id} does not exist."
    end
  end

  def self.find_attribute_value(attribute, value)
    all.find {|instance| instance.send(attribute) == value}
  end

  def self.destroy(id)
    instance = find(id)
    if (instance)
      table = CSV.table(@@data_path)
      table.delete_if do |row|
        row[:id] == id
      end
      File.open(@@data_path, 'w') do |f|
        f.write(table.to_csv)
      end
      return instance
    else
      raise ProductNotFoundError, "Product with id #{id} does not exist."
    end
  end

  def self.method_missing(method_name, *arguments)
    attr_name = method_name.to_s.split('_').last
    if (is_valid_method_prefix?(method_name.to_s) && is_valid_method_sufix?(attr_name) && arguments.length == 1)
      create_finder_methods(attr_name.to_sym)
      return self.send(method_name.to_sym, arguments.first)
    else
      puts "No method named #{method_name}"
    end
  end

  def self.where(opts = {})
    attr_name = nil
    attr_value = nil
    opts.each do |key, value|
      attr_name = key
      attr_value = value
    end
    all.select {|instance| instance.send(attr_name) == attr_value.to_s}
  end

  def update(opts = {})
    update_attributes(opts)
    self.class.destroy(self.id)
    row = convert_instance_to_array
    opts = {}
    self.class.get_attr_in_csv_order.each_with_index do |header, index|
      opts[header] = row[index]
    end
    self.class.create(opts)
    return self
  end

  private
  
  def self.exist_row_with_id?(id)
    CSV.foreach(@@data_path) do |row|
      return true if row.first == id
    end
    return false
  end

  def self.save(id, attributes)
    row = [id]
    attributes.each do |key, value|
      row << value if key != :id
    end
    CSV.open(@@data_path, "a") do |csv|
      csv << row
    end
  end

  def self.get_object_at(index)
    create_instance_from_array(@@rows[index])
  end

  def self.create_instance_from_array(row)
    attributes = {}
    headers = get_attr_in_csv_order
    row.each.with_index do |attribute, index|
      attributes[headers[index.to_i].to_sym] = attribute        
    end
    self.new(attributes)
  end

  def self.is_valid_method_prefix?(method_name)
    method_name.start_with?("find_by_")
  end

  def self.is_valid_method_sufix?(attr_name)
    get_attr_in_csv_order.include?(attr_name.to_sym)
  end

  def update_attributes(opts = {})
    opts.each do |key, value|
      if value.class.to_s == 'String'
        self.instance_eval("@#{key.to_s} = '#{value}'")
      else
        self.instance_eval("@#{key.to_s} = #{value}")
      end
    end
  end

  def convert_instance_to_array
    row = []
    headers = self.class.get_attr_in_csv_order
    4.times do |index|
      row[index] = self.instance_eval("@#{headers[index].to_s}")
    end
    return row
  end

end
