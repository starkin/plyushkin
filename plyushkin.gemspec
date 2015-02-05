# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'plyushkin/version'

Gem::Specification.new do |spec|
  spec.name          = "plyushkin"
  spec.version       = Plyushkin::VERSION
  spec.authors       = ["Craig Israel", "Jeremy Hinkle"]
  spec.email         = ["craig@theisraels.net", "jchinkle@gmail.com"]
  spec.description   = %q{Provides active record extension to capture historical property data}
  spec.summary       = %q{Plyushkin - the attribute hoarder}
  spec.homepage      = "http://github.com/starkin/plyushkin"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", "~> 3.2.12"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
