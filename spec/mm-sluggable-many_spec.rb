require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoMapper::Plugins::Sluggable" do

  describe 'for many elements it should work fine' do
    before do(:each)
      Cow = Class.new do
        include MongoMapper::Document
        plugin MongoMapper::Plugins::Sluggable
        key :name
        sluggable :name
      end
      Cow.collection.remove
    end

    after(:each) do
      Object.send(:remove_const, :Cow)
    end

    it "should work fine after 20" do
      test_klass = Cow.create(:name => "moohser", :description => "should add the first version of moohser")
      (1..15).each do |num|
        test_klass = Cow.create(:name => "moohser", :description => "should add a version of moohser (#{num}) if the slug conflicts")
        test_klass.slug.should eq("moohser-#{num}")
      end
    end

    it "should work fine after 100" do
      test_klass = Cow.create(:name => "moohser", :description => "should add the first version of moohser")
      (1..15).each do |num|
        test_klass = Cow.create(:name => "moohser", :description => "should add a version of moohser (#{num}) if the slug conflicts")
        test_klass.slug.should eq("moohser-#{num}")
      end
    end

  end


end