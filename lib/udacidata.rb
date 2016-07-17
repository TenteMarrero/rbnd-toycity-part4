require_relative 'find_by'
require_relative 'errors'
require 'csv'

class Udacidata
  @@data_path = File.dirname(__FILE__) + "/../data/data.csv"
  @@rows = []
  @@headers = []
  @@headers_symb = []


  def self.create(attributes = nil)
    object = self.new(attributes)
    unless exist_row_with_id?(object.id)
      save(object.id, attributes)
    end
    return object
  end

  def self.all
    load_data
    @@rows.map do |row|
      create_instance_from_array(row)
    end
  end

  def self.first(n = nil)
    load_data
    if n
      @@rows.first(n).map {|row| create_instance_from_array(row)}
    else
      create_instance_from_array(@@rows.first)
    end
  end

  def self.last(n = nil)
    load_data
    if n
      @@rows.last(n).map {|row| create_instance_from_array(row)}
    else
      create_instance_from_array(@@rows.last)
    end
  end

  def self.find(id)
    load_data
    self.find_attribute_value(:id, id)
  end

  def self.find_attribute_value(attribute, value)
    load_data
    attr_order = get_attr_in_csv_order.index(attribute)
    row = @@rows.find {|row| row[attr_order] == value.to_s}
    if row
      create_instance_from_array(row)
    else
      return false
    end
  end

  def self.destroy(id)
    load_data
    index_to_delete = @@rows.index {|row| row.first == id.to_s}
    data_object = get_object_at(index_to_delete)
    @@rows.delete_at(index_to_delete)
    rewrite_file
    return data_object
  end

  def self.method_missing(method_name, *arguments)
    load_data
    attr_name = method_name.to_s.split('_').last
    if (is_valid_method_prefix?(method_name.to_s) && is_valid_method_sufix?(attr_name) && arguments.length == 1)
      create_finder_methods(attr_name.to_sym)
      return self.send(method_name.to_sym, arguments.first)
    else
      puts "No method named #{method_name}"
    end
  end

  def self.where(opts = {})
    load_data
    attr_name = nil
    attr_value = nil
    opts.each do |key, value|
      attr_name = key
      attr_value = value
    end 
    attr_order = get_attr_in_csv_order.index(attr_name.to_sym)
    results = @@rows.select {|row| row[attr_order] == attr_value.to_s}
    results.map {|result| create_instance_from_array(result)}
  end

  def update(opts = {})
    update_attributes(opts)
    update_in_csv
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

  def self.load_data
    @@rows = CSV.read(@@data_path)
    @@headers = @@rows[0]
    @@headers_symb = get_attr_in_csv_order
    @@rows.delete_at(0)
  end

  def self.rewrite_file
    CSV.open(@@data_path, "wb") do |csv|
      csv << @@headers
      @@rows.each {|row| csv << row}
    end
  end

  def self.get_object_at(index)
    create_instance_from_array(@@rows[index])
  end

  def self.create_instance_from_array(row)
    attributes = {}
    row.each.with_index do |attribute, index|
      attributes[@@headers[index.to_i].to_sym] = attribute        
    end
    self.new(attributes)
  end

  def self.is_valid_method_prefix?(method_name)
    method_name.start_with?("find_by_")
  end

  def self.is_valid_method_sufix?(attr_name)
    @@headers_symb.include?(attr_name.to_sym)
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

  def update_in_csv
    self.class.load_data
    index_to_update = @@rows.index {|row| row.first == self.id.to_s}
    @@rows[index_to_update] = convert_instance_to_array
    self.class.rewrite_file
  end

  def convert_instance_to_array
    row = []
    4.times do |index|
      row[index] = self.instance_eval("@#{@@headers_symb[index].to_s}")
    end
    return row
  end

end
