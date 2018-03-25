$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'bucket/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'crab-bucket'
  s.version     = Bucket::VERSION
  s.authors     = ['Anthony Martin']
  s.email       = ['github@martin-studio.com']
  s.homepage    = 'http://github.com/inertia186/crab-bucket'
  s.summary     = 'Plugin for Rails applications to embed the Radiator for STEEM.'
  s.description = 'Allows Rails applications to record a copy of the STEEM blockchain.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 5.0.0', '>= 5.0.0.1'
  s.add_dependency 'radiator'
  s.add_dependency 'haml', '~> 4.0.7'
  s.add_dependency 'sass-rails', '~> 5.0'
  s.add_dependency 'coffee-rails', '~> 4.2'
  s.add_dependency 'bootstrap-glyphicons', '~> 0.0.1'
  s.add_dependency 'angular-ui-bootstrap-rails', '~> 1.3.2'
  s.add_dependency 'will_paginate', '~> 3.1.0'
  
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'yard', '~> 0.8.7.6'
end
