require "json"

module Rspec::RequestSnapshot
  RSpec::Matchers.define :match_snapshot do |snapshot_name, options|
    attr_reader :actual, :expected, :options

    diffable

    match do |actual|
      @options = options || {}

      snapshot_file_path = File.join(RSpec.configuration.request_snapshots_dir, "#{snapshot_name}.json")

      FileUtils.mkdir_p(File.dirname(snapshot_file_path)) unless Dir.exist?(File.dirname(snapshot_file_path))

      if File.exist?(snapshot_file_path) && !(ENV["REPLACE_SNAPSHOTS"] == "true")
        @actual = comparable(replace_dynamic_attributes(actual))
        @expected = comparable(replace_dynamic_attributes(File.read(snapshot_file_path)))
        @actual == @expected
      else
        File.write(snapshot_file_path, writable(comparable(@actual)))
        true
      end
    end

    failure_message do
      [
        "expected: #{expected}",
        "     got: #{actual}"
      ].join("\n")
    end

    def comparable(str)
      case format
      when :text
        str
      when :json
        JSON.parse(str)
      end
    end

    def writable(str)
      case format
      when :text
        str
      when :json
        JSON.pretty_generate(str)
      end
    end

    def format
      @options[:format]&.to_sym || :json
    end

    def replace_dynamic_attributes(json)
      dynamic_attributes.each do |attribute|
        json.gsub!(/\"#{attribute}\":\s*(\".*?\"|\d+|\w+)/, "\"#{attribute}\":\"REPLACED\"")
      end
      json
    end

    def dynamic_attributes
      @dynamic_attributes ||= RSpec.configuration.request_snapshots_dynamic_attributes |
                              Array(options[:dynamic_attributes])
    end
  end
end
