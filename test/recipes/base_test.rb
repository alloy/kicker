require File.expand_path('../../test_helper', __FILE__)
require 'kicker/recipes/base'

describe "The Kicker::Recipes::Base class, when being called" do
  it "should instantiate a new instance and call the #handle! method" do
    kicker = Kicker.new({})
    files = %w{}
    instance = mock('Kicker::Recipes::Rails')
    
    Kicker::Recipes::Base.expects(:new).with(kicker, files).returns(instance)
    instance.expects(:handle!)
    
    Kicker::Recipes::Base.call(kicker, files)
  end
end

describe "An instance of Kicker::Recipes::Base" do
  before do
    @kicker = Kicker.new({})
    @files = %w{}
  end
  
  it "should assign the kicker instance and files array" do
    instance = Kicker::Recipes::Base.new(@kicker, @files)
    instance.kicker.should.be @kicker
    instance.files.should.be @files
  end
  
  it "should call the #after_initialize method when done initializing if it exists" do
    lambda { Kicker::Recipes::Base.new(@kicker, @files) }.should.not.raise
    
    Kicker::Recipes::Base.any_instance.expects(:after_initialize)
    Kicker::Recipes::Base.new(@kicker, @files)
  end
  
  it "should raise a Kicker::Recipes::Base::NotImplementedError if the subclass doesn't implement #handle!" do
    lambda {
      Kicker::Recipes::Base.new(@kicker, @files).handle!
    }.should.raise Kicker::Recipes::Base::NotImplementedError
  end
  
  it "should return a relative representation of a given path, relative to the working dir" do
    path = 'lib/foo.rb'
    instance = Kicker::Recipes::Base.new(@kicker, @files)
    instance.relative_path(File.expand_path(path)).should == path
  end
end