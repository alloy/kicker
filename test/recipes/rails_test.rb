require File.expand_path('../../test_helper', __FILE__)

before = Kicker.process_chain.dup
require 'kicker/recipes/rails'
rails = (Kicker.process_chain - before).first

describe "The Rails handler" do
  # before do
  #   Kicker::Utils.stubs(:execute)
  # end
  
  it "should match, extract, and run any test case files that have changed" do
    test_files = %w{ test/1_test.rb test/namespace/2_test.rb }
    files = test_files + %w{ lib/foo.rb }
    
    Kicker::Utils.expects(:run_ruby_tests).with(test_files)
    rails.call(files)
    files.should == %w{ lib/foo.rb }
  end
end