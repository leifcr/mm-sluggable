require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoMapper::Plugins::Sluggable" do

  before(:each) do
    @klass = Class.new do
      include MongoMapper::Document
      set_collection_name :articles

      plugin MongoMapper::Plugins::Sluggable

      key :title,       String
      key :account_id,  Integer
      key :description, String
    end
  end

  describe "with defaults" do
    before(:each) do
      @klass.sluggable :title
      @article = @klass.new(:title => "testing 123")
    end

    it "should add a key called :slug" do
      @article.keys.keys.should include("slug")
    end

    it "should set the slug on validation" do
      lambda{
        @article.valid?
      }.should change(@article, :slug).from(nil).to("testing-123")
      @article.save
    end

    it "should add a version number (1) if the slug conflicts" do
      test_klass = @klass.create(:title => "testing 123", :description => "should add a version number (1) if the slug conflicts")
      test_klass.slug.should eq("testing-123-1")
    end

    it "should truncate slugs over the max_length default of 256 characters" do
      @article.title = "a" * 300
      @article.valid?
      @article.slug.length.should == 256
    end

    it "should not change the slug on update" do
      # this saves testing-123-2
      @article.save
      check_slug = @article.slug
      @article.description = "new description"
      @article.save
      @article.slug.should eq(check_slug)
    end

    describe "testing inbetween replacements" do
      it "should add a version number (3) if the slug conflicts" do
        test_klass = @klass.create(:title => "testing 123", :description => "should add a version number (3) if the slug conflicts")
        test_klass.slug.should eq("testing-123-3")
      end

      it "should add a version number (4) if the slug conflicts" do
        test_klass = @klass.create(:title => "testing 123", :description => "should add a version number (4) if the slug conflicts")
        test_klass.slug.should eq("testing-123-4")
      end

      it "should add a version number (5) if the slug conflicts" do
        test_klass = @klass.create(:title => "testing 123", :description => "should add a version number (5) if the slug conflicts")
        test_klass.slug.should eq("testing-123-5")
      end

      it "should remove version (3) in between" do
        test_klass = @klass.where(:slug => "testing-123-3").first
        test_klass.destroy
        @klass.where(:slug => "testing-123-3").first.should eq(nil)
      end

      it "should add a version number (3) since it was destroyed and there is an open space" do
        test_klass = @klass.create(:title => "testing 123", :description => "should add a version number (3) if the slug conflicts")
        test_klass.slug.should eq("testing-123-3")
      end

      it "should remove version (2) in between" do
        test_klass = @klass.where(:slug => "testing-123-2").first
        test_klass.destroy
        @klass.where(:slug => "testing-123-2").first.should eq(nil)
      end

      it "should add a version number (2) since it was destroyed and there is an open space" do
        test_klass = @klass.create(:title => "testing 123", :description => "should add a version number (2) if the slug conflicts")
        test_klass.slug.should eq("testing-123-2")
      end

      it "should remove initial version" do
        test_klass = @klass.where(:slug => "testing-123").first
        test_klass.destroy
        @klass.where(:slug => "testing-123").first.should eq(nil)
      end

      it "should add not add a version number since it was destroyed and there is an open space" do
        @article.save
        @article.slug.should eq("testing-123")
      end

    end
  end

  describe "drop the current klasses, to avoid conflict for further tests" do
    it "should drop current klass db" do
      @klass.collection.remove
    end
  end

  describe "with different key" do
    before(:each) do
      @klass.sluggable :title, :key => :title_slug
      @article = @klass.new(:title => "testing 123")
    end

    it "should add the specified key" do
      @article.keys.keys.should include("title_slug")
    end

    it "should set the slug on validation" do
      lambda{
        @article.valid?
      }.should change(@article, :title_slug).from(nil).to("testing-123")
    end
  end

  describe "with different slugging method" do
    before(:each) do
      @klass.sluggable :title, :method => :upcase
      @article = @klass.new(:title => "testing 123")
    end

    it "should set the slug using the specified method" do
      lambda{
        @article.valid?
      }.should change(@article, :slug).from(nil).to("TESTING 123")
    end
  end

  describe "with a different callback" do
    before(:each) do
      @klass.sluggable :title, :callback => :before_create
      @article = @klass.new(:title => "testing 123")
    end

    it "should not set the slug on the default callback" do
      lambda{
        @article.valid?
      }.should_not change(@article, :slug)
    end

    it "should set the slug on the specified callback" do
      lambda{
        @article.save
      }.should change(@article, :slug).from(nil).to("testing-123")
    end
  end

  describe "with custom max_length" do
    before(:each) do
      @klass.sluggable :title, :max_length => 5
      @article = @klass.new(:title => "testing 123")
    end

    it "should truncate slugs over the max length" do
      @article.valid?
      @article.slug.length.should == 5
    end
  end

  describe "drop everything when closing" do
    it "should drop all the good stuff" do
      @klass.collection.remove
    end
  end

end