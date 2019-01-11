module Rspec::RequestSnapshot
  RSpec.configure do |config|
    config.add_setting :request_snapshots_dir, default: "spec/fixtures/snapshots"
    config.add_setting :request_snapshots_dynamic_attributes, default: %w(id created_at updated_at)
    config.add_setting :request_snapshots_ignore_order, default: %w()
  end
end
