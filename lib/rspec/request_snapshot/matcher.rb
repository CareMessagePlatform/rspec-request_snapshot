module Rspec::RequestSnapshot
  RSpec::Matchers.define :match_snapshot do |snapshot_name, options|
    attr_reader :actual, :expected, :options

    diffable

    match do |actual|
      @options = options || {}

      snapshot_file_path = File.join(RSpec.configuration.request_snapshots_dir, "#{snapshot_name}.json")

      FileUtils.mkdir_p(File.dirname(snapshot_file_path)) unless Dir.exist?(File.dirname(snapshot_file_path))

      if File.exist?(snapshot_file_path) && !(ENV["REPLACE_SNAPSHOTS"] == "true")
        @actual = handler.comparable(actual)
        @expected = handler.comparable(File.read(snapshot_file_path))

        handler.compare(@actual, @expected)
      else
        File.write(snapshot_file_path, handler.writable(actual))
        true
      end
    end

    failure_message do
      [
        "expected: #{expected}",
        "     got: #{actual}"
      ].join("\n")
    end

    def format
      @options[:format]&.to_sym || RSpec.configuration.request_snapshots_default_format
    end

    def handler
      @handler ||= begin
        handler_class = case format
        when :text
          Handlers::Text
        when :json
          Handlers::JSON
        end
        handler_class.new(@options)
      end
    end
  end
end
