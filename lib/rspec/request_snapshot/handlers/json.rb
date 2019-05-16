# frozen_string_literal: true

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
    hash.each_key do |key|
      if dynamic_attributes.include?(key)
        handle_dynamic_attribute(hash, key)
        next
      end

      if hash[key].is_a?(Hash)
        deep_transform_values(hash[key])
        next
      end

      deep_transform_array(hash, key) if hash[key].is_a?(Array)
    end
  end

  def deep_transform_array(hash, key)
    hash[key].each do |value|
      deep_transform_values(value) if value.is_a?(Hash)
    end

    sort_elements(hash, key) if ignore_order.include?(key)
  end

  def sort_elements(hash, key)
    hash[key].first.is_a?(Hash) ? hash[key].sort_by! { |e| e.keys.map { |k| e[k] } } : hash[key].sort_by!(&:to_s)
  end

  def handle_dynamic_attribute(hash, key)
    if dynamic_attributes_with_regex.key?(key)
      hash[key] = dynamic_attributes_with_regex[key] if dynamic_attributes_with_regex[key].match(hash[key].to_s)
    else
      hash[key] = "IGNORED"
    end
  end
end
