# frozen_string_literal: true

class Rspec::RequestSnapshot::Updaters::JSON < Rspec::RequestSnapshot::Updaters::Base
  def update(expected_json, snapshot_file_path)
    expected_json = JSON.parse(expected_json)
    stored_json = JSON.parse(File.read(snapshot_file_path))

    deep_update(expected_json, stored_json)

    File.write(snapshot_file_path, JSON.pretty_generate(stored_json))
  end

  private

  def deep_update(expected_json, stored_json)
    case expected_json
    when Array
      deep_update_array(expected_json, stored_json)
    when Hash
      deep_update_hash(expected_json, stored_json)
    end
  end

  def deep_update_hash(expected_json, stored_json)
    keys = expected_json.keys | stored_json.keys
    keys.each do |key|
      # If key present on expected and not stored, add it to stored
      unless stored_json.key?(key)
        stored_json[key] = expected_json[key]
        next
      end

      # If key only present on stored, remove it from stored
      unless expected_json.key?(key)
        stored_json.delete(key)
        next
      end

      # If key present on both, and not a dynamic attribute, update the stored one
      unless dynamic_attributes.include?(key)
        if expected_json[key].is_a?(Hash) || expected_json[key].is_a?(Array)
          deep_update(expected_json[key], stored_json[key])
        else
          stored_json[key] = expected_json[key]
        end
      end
    end
  end

  def deep_update_array(expected_json, stored_json)
    max_size = [expected_json.size, stored_json.size].max

    0.upto(max_size).each do |index|
      # If element is only present on expected, add it to stored
      stored_json[index] = expected_json[index] if !stored_json[index] && expected_json[index]

      # If element is only present on stored, remove it from stored
      stored_json.delete_at(index) if !expected_json[index] && stored_json[index]

      deep_update(expected_json[index], stored_json[index])
    end
  end
end
