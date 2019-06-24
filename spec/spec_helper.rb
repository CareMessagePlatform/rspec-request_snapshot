# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "bundler/setup"
require "rspec/request_snapshot"
require "climate_control"

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
