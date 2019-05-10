# frozen_string_literal: true

module Rspec::RequestSnapshot::Handlers
  class Base
    attr_reader :dynamic_attributes_with_regex

    def initialize(options = {})
      @options = options
    end

    def dynamic_attributes
      @dynamic_attributes ||= begin
        list = RSpec.configuration.request_snapshots_dynamic_attributes | Array(@options[:dynamic_attributes])
        strip_attributes_with_regex(list)
      end
    end

    def ignore_order
      @ignore_order ||= RSpec.configuration.request_snapshots_ignore_order |
                        Array(@options[:ignore_order])
    end

    private

    def strip_attributes_with_regex(list)
      @dynamic_attributes_with_regex = {}
      list.map do |element|
        if element.is_a?(String)
          element
        else
          key = element.keys.first.to_s
          @dynamic_attributes_with_regex[key] = element.values.first
          key
        end
      end
    end
  end
end
