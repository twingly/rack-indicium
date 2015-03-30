# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/indicium/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-indicium"
  spec.version       = Rack::Indicium::VERSION
  spec.authors       = ["Twingly AB"]
  spec.email         = ["support@twingly.com"]

  spec.summary       = %q{Rack JWT helpers}
  spec.homepage      = "https://github.com/twingly/rack-indicium"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "jwt", "~> 1.4"
  spec.add_dependency  "rack", "~> 1.6"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "rack-test", "~> 0.6"
  spec.add_development_dependency "sinatra", "~> 1.4"
  spec.add_development_dependency "grape", "~> 0.11"
  spec.add_development_dependency "json", "~> 1.7"
end
