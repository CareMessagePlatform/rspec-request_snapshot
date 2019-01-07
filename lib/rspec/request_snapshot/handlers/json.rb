class Rspec::RequestSnapshot::Handlers::JSON < Rspec::RequestSnapshot::Handlers::Base
  def compare(actual, expected)
    equal = true

    actual.each do |key, value|
      if actual[key].is_a?(Hash)
        equal &= compare_hash(key, actual, expected)
      elsif actual[key].is_a?(Array)
        equal &= compare_array(key, actual, expected)
      else
        equal &= compare_value(key, actual, expected)
      end
    end

    equal
  end

  def comparable(str)
    JSON.parse(str)
  end

  def writable(str)
    JSON.pretty_generate(JSON.parse(str))
  end

  private

  def compare_hash(key, actual, expected)
    actual[key].is_a?(Hash) && expected[key].is_a?(Hash) && compare(actual[key], expected[key])
  end

  def compare_array(key, actual, expected)
    if actual[key].is_a?(Array) && expected[key].is_a?(Array)
      if @options[:ignore_order] && @options[:ignore_order].include?(key)
        actual[key].sort == expected[key].sort
      else
        actual[key] == expected[key]
      end
    end
  end

  def compare_value(key, actual ,expected)
    dynamic_attributes.include?(key) ? true : actual[key] == expected[key]
  end
end
