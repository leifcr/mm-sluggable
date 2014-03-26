require "bundler/gem_tasks"
require 'rspec/core/rake_task'

require File.join(File.dirname(__FILE__), 'lib', 'sluggable', 'version')

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

gemspec = eval(File.read("mm-sluggable.gemspec"))
