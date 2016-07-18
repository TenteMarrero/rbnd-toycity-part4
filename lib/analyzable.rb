module Analyzable
  # Your code goes here!
  def print_report(products)
    print_average_price(products) + "\n" +
    "Inventory by brand:" + "\n" +
    print_brand_report(products) + "\n" +
    "Inventory by name:" + "\n" +
    print_name_report(products)
  end

  def print_average_price(products)
    "Average Price: #{average_price(products).to_s}"
  end

  def average_price(products)
    (products.inject(0.0) { |result, product| result + product.price.to_f } / products.length.to_f).round(2)
  end

  def print_brand_report(products)
    brands = count_by_brand(products)
    print_lines(brands)
  end

  def count_by_brand(products)
    count_by("brand", products)
  end

  def print_name_report(products)
    names = count_by("name", products)
    print_lines(names)
  end

  def count_by_name(products)
    count_by("name", products)
  end

  def print_lines(report_hash)
    lines = report_hash.map do |key, value|
      "- #{key}: #{value}"
    end
    report = ""
    lines.each {|line| report += line + "\n"}
    return report
  end

  def count_by(attribute, products)
    results = {}
    products.each do |product|
        value = product.instance_eval("@#{attribute}")
        if results[value] == nil
          results[value] = 1
        else
          results[value] += 1
        end
    end
    return results
  end
end
