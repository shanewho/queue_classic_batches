# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'queue_classic_batches/version'

Gem::Specification.new do |spec|
  spec.name          = "queue_classic_batches"
  spec.version       = QueueClassicBatches::VERSION
  spec.authors       = ["Shane"]
#  spec.email         = ["shane@....com"]
  spec.description   = %q{Adds batch functionality to the queue_classic gem}
  spec.summary       = %q{Adds batch functionality to the queue_classic gem}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "queue_classic", "~> 3.0.0rc"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0.0.beta"
  spec.add_development_dependency "activerecord", "~> 4"
end
