# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'perf/version'

Gem::Specification.new do |spec|
  spec.name          = "perf"
  spec.version       = Perf::VERSION
  spec.authors       = ["aliakb"]
  spec.email         = ["abaturytski@gmail.com"]
  spec.description   = 'Library for collecting performance data.'
  spec.summary       = 'Performance counters for Ruby projects.'
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "redis"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "uuid"
  spec.add_development_dependency "mock_redis"
  spec.add_development_dependency "simplecov"
end
