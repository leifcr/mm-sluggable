# -*- encoding: utf-8 -*-
require File.join File.dirname(__FILE__), '/lib/sluggable/version'

Gem::Specification.new do |s|
  s.name              = %q{mm-sluggable}
  s.homepage          = %q{http://github.com/luuf/mm-sluggable}

  s.summary           = %q{Tiny plugin for MongoMapper to cache a slugged version of a field. Based on Richard Livseys plugin}

  s.authors           = ["Leif Ringstad"]
  s.email             = %q{leifcr@gmail.com}
  s.version           = Sluggable::VERSION
  s.platform          = Gem::Platform::RUBY
  # s.files             = [ "Gemfile",
  #                         "LICENSE", 
  #                         "Rakefile", 
  #                         "README.rdoc", 
  #                         "spec", 
  #                         "lib/mm-sluggable.rb"
  #                         "lib/sluggable/version.rb"
  #                       ]
  # s.test_files        = Dir.glob('test/**/*')
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.require_paths     = ["lib"]

  #s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.date              = %q{2012-02-14}
  #s.extra_rdoc_files  = ["README.rdoc"]
  #s.rdoc_options      = ["--main", "README.rdoc"]
  s.rubygems_version  = %q{1.6.2}

  s.add_dependency("mongo_mapper", [">= 0.12.0"])
  s.add_development_dependency(%q<rspec>, [">= 0"])

end
