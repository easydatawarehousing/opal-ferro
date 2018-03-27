# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opal-ferro/version'

Gem::Specification.new do |s|
  s.name          = 'opal-ferro'
  s.version       = Opal::Ferro::VERSION
  s.author        = ['Ivo Herweijer']
  s.email         = ['info@edwhs.nl']

  s.summary       = %q{Simplifying web-development: no more html, just beautiful and simple Ruby code.}
  s.description   = %q{Ferro is a small Ruby library on top of Opal that enables an object-oriented programming style for creating code that runs in the webbrowser. No more distractions like HTML and searching for DOM elements, just beautiful and simple Ruby code. Front-End-Ruby-ROcks!}
  s.homepage      = 'https://github.com/easydatawarehousing/opal-ferro'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.require_paths = ['lib']

  s.add_dependency 'opal', '~> 0.10'

  s.add_development_dependency 'bundler',  '~> 1.16'
  s.add_development_dependency 'rake',     '~> 10.0'
  s.add_development_dependency 'yard',     '~> 0.9.12'
  s.add_development_dependency 'minitest', '~> 5.0'
  # s.add_development_dependency 'selenium-webdriver', '~> 3.8'
end