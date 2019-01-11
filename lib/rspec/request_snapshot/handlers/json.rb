class Rspec::RequestSnapshot::Handlers::JSON < Rspec::RequestSnapshot::Handlers::Base
  def compare(actual, expected)
    actual == expected
  end

  def comparable(str)
    deep_transform_values(JSON.parse(str).dup)
  end

  def writable(str)
    JSON.pretty_generate(JSON.parse(str))
  end

  private

  def deep_transform_values(hash)
    hash.each do |key, value|
      if dynamic_attributes.include?(key)
        hash[key] = "REPLACED"
      end

      if hash[key].is_a?(Hash)
        deep_transform_values(hash[key])
      end

      if hash[key].is_a?(Array)
        hash[key].each do |value|
          deep_transform_values(value) if value.is_a?(Hash)
        end

        if ignore_order.include?(key)
          hash[key].first.is_a?(Hash) ? hash[key].sort_by! { |e| e.keys.map { |k| e[k] } } : hash[key].sort!
        end
      end
    end
  end
end
