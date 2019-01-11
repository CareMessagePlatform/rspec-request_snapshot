module Rspec::RequestSnapshot::Handlers
  class Base
    def initialize(options = {})
      @options = options
    end

    def dynamic_attributes
      @dynamic_attributes ||= RSpec.configuration.request_snapshots_dynamic_attributes |
                              Array(@options[:dynamic_attributes])
    end

    def ignore_order
      @ignore_order ||= RSpec.configuration.request_snapshots_ignore_order |
                        Array(@options[:ignore_order])
    end
  end
end
