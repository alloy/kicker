require File.expand_path('../../test_helper', __FILE__)
require 'kicker/recipes/ruby_test_runner'

describe "The Kicker::Recipes::RubyTestRunner handler" do
  before do
    @handler = Kicker::Recipes::RubyTestRunner.new([])
  end
  
  it "should have a test_files array" do
    @handler.test_files.should == []
  end
  
  it "should run the test files with ruby" do
    @handler.test_files << 'test/1.rb'
    @handler.test_files << 'test/2.rb'
    Kicker.expects(:execute_command).with("ruby -r test/1.rb -r test/2.rb -e ''")
    @handler.run_tests
  end
  
  it "should not run the tests if there are none" do
    Kicker.expects(:execute_command).never
    @handler.run_tests
  end
end