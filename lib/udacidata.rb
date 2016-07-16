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
    load_data
    @rows.map do |row|
      self.new(get_attributes(row))
    end
  end

  def self.first(n = nil)
    load_data
    if n
      @rows.first(n).map do |row|
        self.new(get_attributes(row))
      end
    else
      attributes = get_attributes(@rows.first)
      self.new(attributes)
    end
  end

  def self.last(n = nil)
    load_data
    if n
      @rows.last(n).map do |row|
        self.new(get_attributes(row))
      end
    else
      attributes = get_attributes(@rows.last)
      self.new(attributes)
    end
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

  def self.load_data() 
    @rows = CSV.read(@@data_path)
    @headers = @rows[0]
    @rows.delete_at(0)
  end

  def self.get_attributes(row)
    attributes = {}
    row.each.with_index do |attribute, index|
      attributes[@headers[index.to_i].to_sym] = attribute        
    end
    #TODO: send attributes as id:
    return attributes;
  end

end
