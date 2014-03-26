require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoMapper::Plugins::Sluggable" do
  describe "with SCI" do
    before do
      Animal = Class.new do
        include MongoMapper::Document
        key :name
      end
      Animal.collection.remove

      Dog = Class.new(Animal)
    end

    after do
      Object.send(:remove_const, :Animal)
      Object.send(:remove_const, :Dog)
    end

    describe "when defined in the base class" do
      before do
        Animal.instance_eval do
          plugin MongoMapper::Plugins::Sluggable
          sluggable :name
        end
      end

      it "should scope it to the base class" do
        animal = Animal.new(:name => "rover")
        animal.save!
        animal.slug.should == "rover"

        dog = Dog.new(:name => "rover")
        dog.save!
        dog.slug.should == "rover-1"
      end
    end

    describe "when defined on the subclass" do
      before do
        Dog.instance_eval do
          plugin MongoMapper::Plugins::Sluggable
          sluggable :name
        end
      end

      it "should scope it to the subclass" do
        animal = Animal.new(:name => "rover")
        animal.save!
        animal.should_not respond_to(:slug)

        dog = Dog.new(:name => "rover")
        dog.save!
        dog.slug.should == "rover"
      end
    end
  end

end
