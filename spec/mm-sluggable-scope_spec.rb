require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoMapper::Plugins::Sluggable" do

  before(:all) do
    Scoped = Class.new do
      include MongoMapper::Document
      set_collection_name :articles

      plugin MongoMapper::Plugins::Sluggable

      key :title,       String
      key :account_id,  Integer
      key :description, String
    end
  end

  after(:all) do
    Scoped.collection.remove
    Object.send(:remove_const, :Scoped)
  end

  describe "with scope" do
    before(:each) do
      Scoped.sluggable :title, :scope => :account_id
      @article = Scoped.new(:title => "testing 123", :account_id => 1)
    end

    it "should save initial version with account_id scope" do
      @article.save
      test_klass = @article
      test_klass.slug.should eq("testing-123")
    end

    it "should add a version number if the slug conflics in the scope" do
      test_klass = Scoped.create(:title => "testing 123", :account_id => 1, :description => "should add a version number if the slug conflics in the scope")
      test_klass.slug.should eq("testing-123-1")
    end

    it "should not add a version number if the slug conflicts in a different scope" do
      test_klass = Scoped.create(:title => "testing 123", :account_id => 2, :description => "should not add a version number if the slug conflicts in a different scope")
      test_klass.slug.should eq("testing-123")
    end
  end


end