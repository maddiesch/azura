# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'azura/version'

Gem::Specification.new do |spec|
  spec.name          = 'azura'
  spec.version       = Azura::VERSION
  spec.authors       = ['Skylar Schipper']
  spec.email         = ['ss@schipp.co']

  spec.summary       = 'A JSON-API formatter'
  spec.description   = 'A JSON-API formatter'
  spec.homepage      = 'https://github.com/skylarsch/azura'
  spec.license       = 'MIT'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.files            = Dir['{app,config,db,lib}/**/*', 'Rakefile', 'README.md']
  spec.test_files       = Dir['spec/**/*']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'

  spec.add_dependency 'rails', '>= 5.0', '< 5.2'
end
