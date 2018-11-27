require "simplecov"
SimpleCov.start

require "bundler/setup"
require "rspec/request_snapshot"

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
