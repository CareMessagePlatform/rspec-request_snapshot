lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rspec/request_snapshot/version"

Gem::Specification.new do |spec|
  spec.name          = "rspec-request_snapshot"
  spec.version       = Rspec::RequestSnapshot::VERSION
  spec.authors       = ["Bruno Campos"]
  spec.email         = ["bcampos@caremessage.org"]

  spec.summary       = "Gold master testing for RSpec API request specs"
  spec.description   = "Make sure API behavior is not changing by taking and storing a snapshot from an API response on a first run and check if they match on next spec runs."
  spec.homepage      = "https://github.com/CareMessagePlatform/rspec-request_snapshot"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rspec", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "simplecov", "~> 0.16.1"
  spec.add_development_dependency "climate_control", "~> 0.1.0"
end
