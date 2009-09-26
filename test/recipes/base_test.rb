require File.expand_path('../../test_helper', __FILE__)
require 'kicker/recipes/base'

describe "The Kicker::Recipes::Base class, when being called" do
  it "should instantiate a new instance and call the #handle! method" do
    files = %w{}
    instance = mock('Kicker::Recipes::Rails')
    
    Kicker::Recipes::Base.expects(:new).with(files).returns(instance)
    instance.expects(:handle!)
    
    Kicker::Recipes::Base.call(files)
  end
end

describe "An instance of Kicker::Recipes::Base" do
  before do
    @files = %w{}
  end
  
  it "should assign the files array" do
    instance = Kicker::Recipes::Base.new(@files)
    instance.files.should.be @files
  end
  
  it "should call the #after_initialize method when done initializing if it exists" do
    lambda { Kicker::Recipes::Base.new(@files) }.should.not.raise
    
    Kicker::Recipes::Base.any_instance.expects(:after_initialize)
    Kicker::Recipes::Base.new(@files)
  end
  
  it "should raise a Kicker::Recipes::Base::NotImplementedError if the subclass doesn't implement #handle!" do
    lambda {
      Kicker::Recipes::Base.new(@files).handle!
    }.should.raise Kicker::Recipes::Base::NotImplementedError
  end
end