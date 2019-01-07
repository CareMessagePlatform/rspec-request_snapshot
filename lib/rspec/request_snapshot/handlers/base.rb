module Rspec::RequestSnapshot::Handlers
  class Base
    def initialize(options = {})
      @options = options
    end

    def dynamic_attributes
      @dynamic_attributes ||= RSpec.configuration.request_snapshots_dynamic_attributes |
                              Array(@options[:dynamic_attributes])
    end
  end
end
