# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'silverpop/client/version'

Gem::Specification.new do |spec|
  spec.name          = "silverpop-client"
  spec.version       = Silverpop::Client::VERSION
  spec.authors       = ["Gary Lo"]
  spec.email         = ["glo@merkleinc.com"]
  spec.summary       = %q{Silverpop Ruby Client}
  spec.description   = %q{Silverpop Engage and Transact API Client.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'oauth2'
  spec.add_dependency 'builder'
  spec.add_dependency 'hashie', '~> 2.0'
end
