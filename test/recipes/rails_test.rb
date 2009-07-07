require File.expand_path('../../test_helper', __FILE__)
require 'kicker/recipes/rails'

describe "The Kicker::Recipes::Rails handler" do
  before do
    Kicker.stubs(:execute_command)
    @handler = Kicker::Recipes::Rails.new([])
  end
  
  it "should instantiate a new instance and call the #handle! method when called" do
    files = %w{}
    instance = mock('Kicker::Recipes::Rails')
    instance.expects(:handle!)
    
    Kicker::Recipes::Rails.expects(:new).with(files).returns(instance)
    Kicker::Recipes::Rails.call(files)
  end
  
  it "should match, extract, and run any test case files that have changed" do
    lib_file = File.expand_path('lib/foo.rb')
    @handler.files << lib_file
    @handler.files << File.expand_path('test/1_test.rb')
    @handler.files << File.expand_path('test/namespace/2_test.rb')
    
    Kicker.expects(:execute_command).with("ruby -r test/1_test.rb -r test/namespace/2_test.rb -e ''")
    @handler.handle!
    
    @handler.test_files.should == %w{ test/1_test.rb test/namespace/2_test.rb }
    @handler.files.should == [lib_file]
  end
end