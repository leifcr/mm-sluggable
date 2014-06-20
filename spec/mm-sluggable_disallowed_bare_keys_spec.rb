require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoMapper::Plugins::Sluggable" do

  describe 'for elements with default disallowed bare slugs it' do
    before do(:each)
      TestDoc = Class.new do
        include MongoMapper::Document
        plugin MongoMapper::Plugins::Sluggable
        key :name
        sluggable :name
      end
      TestDoc.collection.remove
    end

    after(:each) do
      Object.send(:remove_const, :TestDoc)
    end

    it "should create 'new-1' for name 'new' and the next 12 should be valid" do
      test_klass = TestDoc.create(:name => "new")
      test_klass.slug.should == "new-1"
      (1..12).each do |num|
        test_klass = TestDoc.create(:name => "new")
        test_klass.slug.should eq("new-#{num+1}")
      end
    end

    it "should create 'create-1' for name 'create'" do
      test_klass = TestDoc.create(:name => "create")
      test_klass.slug.should == "create-1"
      test_klass = TestDoc.create(:name => "create")
      test_klass.slug.should == "create-2"
    end

    it "should create 'update-1' for name 'update'" do
      test_klass = TestDoc.create(:name => "update")
      test_klass.slug.should == "update-1"
      test_klass = TestDoc.create(:name => "update")
      test_klass.slug.should == "update-2"
    end

    it "should create 'edit-1' for name 'edit'" do
      test_klass = TestDoc.create(:name => "edit")
      test_klass.slug.should == "edit-1"
      test_klass = TestDoc.create(:name => "edit")
      test_klass.slug.should == "edit-2"
    end

    it "should create 'destroy-1' for name 'destroy'" do
      test_klass = TestDoc.create(:name => "destroy")
      test_klass.slug.should == "destroy-1"
      test_klass = TestDoc.create(:name => "destroy")
      test_klass.slug.should == "destroy-2"
    end
  end

  describe 'for elements with custom disallowed bare slugs it' do
    before do(:each)
      TestDoc = Class.new do
        include MongoMapper::Document
        plugin MongoMapper::Plugins::Sluggable
        key :name
        sluggable :name, disallowed_bare_slugs: ['habbala']
      end
      TestDoc.collection.remove
    end

    after(:each) do
      Object.send(:remove_const, :TestDoc)
    end

    it "should create 'habbala-1' for name 'habbala" do
      test_klass = TestDoc.create(:name => "habbala")
      test_klass.slug.should == "habbala-1"
    end

    it "should have merged custom bares into default bares" do
      TestDoc.slug_options[:disallowed_bare_slugs].include?("habbala").should be_true
      TestDoc.slug_options[:disallowed_bare_slugs].include?("new").should be_true
      TestDoc.slug_options[:disallowed_bare_slugs].include?("edit").should be_true
      TestDoc.slug_options[:disallowed_bare_slugs].include?("destroy").should be_true
      TestDoc.slug_options[:disallowed_bare_slugs].include?("update").should be_true
      TestDoc.slug_options[:disallowed_bare_slugs].include?("create").should be_true
    end
  end


end