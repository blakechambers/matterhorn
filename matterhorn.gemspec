# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'matterhorn/version'

Gem::Specification.new do |spec|
  spec.name          = "matterhorn"
  spec.version       = Matterhorn::VERSION
  spec.authors       = ["Blake Chambers"]
  spec.email         = ["chambb1@gmail.com"]

  spec.summary       = %q{rails-api + mongo = json-api}
  spec.homepage      = "https://github.com/blakechambers/matterhorn"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'active_model_serializers', '= 0.8.3'
  spec.add_runtime_dependency 'mongoid',                  '~> 4.0'
  spec.add_runtime_dependency "rails-api",                '~> 0.4.0'
  spec.add_runtime_dependency "responders",               "~> 2.0"
  spec.add_runtime_dependency "inheritable_accessors",    ">= 0.1.2"

  spec.add_runtime_dependency "inherited_resources",      "~> 1.6.0"
end
