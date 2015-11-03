# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'slide_rule/version'

Gem::Specification.new do |s|
  s.name          = 'slide_rule'
  s.version       = ::SlideRule::VERSION
  s.authors       = %w(mattnichols fergmastaflex)
  s.email         = ['dev@mx.com']
  s.homepage      = 'https://github.com/mattnichols/slide_rule'
  s.summary       = 'Ruby object distance calculator'
  s.description   = 'Calculates the distance between 2 arbitrary objects using specified fields and algorithms.'
  s.license       = 'MIT'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  ##
  # Dependencies
  #
  s.add_runtime_dependency 'levenshtein', '~> 0.2'

  ##
  # Development Dependencies
  #
  s.add_development_dependency 'rake', '~> 10'
  s.add_development_dependency 'pry', '~> 0'
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rubocop', '~> 0'
end
