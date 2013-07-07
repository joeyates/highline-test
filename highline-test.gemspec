# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'highline/test/version'

Gem::Specification.new do |spec|
  spec.name          = 'highline-test'
  spec.version       = Highline::Test::VERSION
  spec.authors       = ['Joe Yates']
  spec.email         = ['joe.g.yates@gmail.com']
  spec.description   = %q{Test HighLine applications}
  spec.summary       = %q{A micro framework that sets up tests for HighLine applications}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'highline'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'bourne'
  spec.add_development_dependency 'shoulda-matchers'
end

