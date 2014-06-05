$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "maybee/version"

Gem::Specification.new do |s|
  s.name          = 'maybee'
  s.version       = Maybee::VERSION
  s.date          = '2014-06-05'
  s.summary       = 'Simple Model-Based Authorization for Rails'
  s.description   = 'A simple, yet flexible approach to model-based authorization'
  s.authors       = ['Matthias Grosser']
  s.email         = 'mtgrosser@gmx.net'
  s.require_path  = 'lib'
  s.files         = Dir['{lib}/**/*.rb', '{lib}/**/*.yml', 'MIT-LICENSE', 'README.md', 'CHANGELOG', 'Rakefile']
  s.homepage      = 'http://rubygems.org/gems/maybee'
  s.licenses      = ["MIT"]
  
  s.add_dependency 'i18n', '>= 0.6.9'
  s.add_dependency 'activerecord', '~> 4.1.1'
  s.add_dependency 'activesupport', '~> 4.1.1'
  
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rake', '>= 0.8.7'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'minitest'
end
