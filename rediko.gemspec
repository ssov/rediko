# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rediko/version'

Gem::Specification.new do |spec|
  spec.name          = "rediko"
  spec.version       = Rediko::VERSION
  spec.authors       = ["Toshiyuki Shimanuki"]
  spec.email         = ["happy.new@nyaa.info"]
  spec.description   = %q{Radiko recorder}
  spec.summary       = %q{Radiko recorder}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
