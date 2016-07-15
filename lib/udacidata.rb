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
    headers = rows[0]
    rows.delete_at(0)
    rows.map do |row|
      attributes = {}
      row.each.with_index do |index, attribute|
        attributes[headers[index.to_i-1]] = attribute        
      end
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
end
