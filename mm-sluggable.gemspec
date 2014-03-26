# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'lib', 'sluggable', 'version')

Gem::Specification.new do |s|
  s.name                          = "leifcr-mm-sluggable"
  s.homepage                      = "http://github.com/leifcr/mm-sluggable"
  s.summary                       = "MongoMapper Plugin to store a slugged version of of a field."

  s.authors                       = ["Leif Ringstad"]
  s.email                         = ["leifcr@gmail.com"]
  s.version                       = Sluggable::VERSION
  s.platform                      = Gem::Platform::RUBY
  s.files                         = Dir.glob('lib/**/*') + %w[Gemfile Rakefile LICENSE README.md]
  s.test_files                    = Dir.glob('test/**/*')

  s.require_paths                 = ["lib"]


  s.add_dependency 'mongo_mapper'

  s.add_development_dependency("rspec", [">= 0"])

end
