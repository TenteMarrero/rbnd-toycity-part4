class Module
  def create_finder_methods(*attributes)
    # Your code goes here!
    # Hint: Remember attr_reader and class_eval
    attributes.each do |attribute|
      new_method = %Q{
         def self.find_by_#{attribute}(value)
            self.find_attribute_value(:#{attribute}, value)
         end
      }
      class_eval(new_method)
    end
  end
end