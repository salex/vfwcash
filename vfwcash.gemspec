# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vfwcash/version'

Gem::Specification.new do |spec|
  spec.name          = "vfwcash"
  spec.version       = Vfwcash::VERSION
  spec.authors       = ["Steve Alex"]
  spec.email         = ["salex@mac.com"]
  spec.summary       = %q{Simple command line tool/pseudo API to generate PDF reports from GNUCash.}
  spec.description   = %q{Simple command line tool/pseudo API to generate PDF reports from GNUCash..}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency 'thor'
  spec.add_dependency 'sqlite3'
  spec.add_dependency 'activerecord'
  spec.add_dependency "prawn-table"
  spec.add_dependency "prawn", '~> 1.3'
  spec.add_dependency 'chronic'

end
