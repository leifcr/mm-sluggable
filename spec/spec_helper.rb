$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
elsif ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require 'mm-sluggable'

MongoMapper.database = 'mm-sluggable-spec'

def article_class
  klass = Class.new do
    include MongoMapper::Document
    set_collection_name :articles

    plugin MongoMapper::Plugins::Sluggable

    key :title,       String
    key :account_id,  Integer
    key :description, String
  end

  #klass.collection.remove
  klass
end

RSpec.configure do |config|
end
