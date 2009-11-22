require File.expand_path('../../test_helper', __FILE__)

before = Kicker.process_chain.dup
require 'kicker/recipes/ruby'
RUBY_FILES = (Kicker.process_chain - before).first

describe "The Ruby handler" do
  before do
    File.stubs(:exist?).with('test/1_test.rb').returns(true)
    File.stubs(:exist?).with('test/namespace/2_test.rb').returns(true)
  end
  
  it "should instantiate a Ruby instance" do
    handler = mock('Ruby', :handle! => nil, :run_tests => nil)
    Ruby.expects(:new).with(%w{ test/1_test.rb Rakefile test/namespace/2_test.rb }).returns(handler)
    RUBY_FILES.call(%w{ test/1_test.rb Rakefile test/namespace/2_test.rb })
  end
  
  it "should run collected tests" do
    handler = Ruby.new([])
    handler.tests.concat %w{ test/1_test.rb test/namespace/2_test.rb }
    handler.expects(:execute).with("ruby -r test/1_test.rb -r test/namespace/2_test.rb -e ''")
    handler.run_tests
  end
  
  it "should run collected tests with a spec runner" do
    handler = Ruby.new(%w{ lib/1.rb spec/namespace/2_spec.rb })
    def handler.test_type; 'spec'; end
    File.stubs(:exist?).with('spec/1_spec.rb').returns(true)
    File.stubs(:exist?).with('spec/namespace/2_spec.rb').returns(true)
    handler.handle!
    
    handler.expects(:execute).with("spec spec/1_spec.rb spec/namespace/2_spec.rb")
    handler.run_tests
  end
  
  it "should not try to run the tests if none were collected" do
    handler = Ruby.new([])
    handler.expects(:execute).never
    handler.run_tests
  end
  
  it "should match any test case files" do
    files = %w{ Rakefile test/1_test.rb test/namespace/2_test.rb }
    handler = Ruby.new(files)
    handler.handle!
    
    handler.tests.should == %w{ test/1_test.rb test/namespace/2_test.rb }
    files.should == %w{ Rakefile }
  end
  
  it "should match files in ./lib" do
    files = %w{ Rakefile lib/1.rb lib/namespace/2.rb }
    handler = Ruby.new(files)
    handler.handle!
    
    handler.tests.should == %w{ test/1_test.rb test/namespace/2_test.rb }
    files.should == %w{ Rakefile }
  end
  
  it "should match lib tests in the test root as well" do
    File.stubs(:exist?).with('test/namespace/2_test.rb').returns(false)
    File.stubs(:exist?).with('test/2_test.rb').returns(true)
    
    files = %w{ Rakefile lib/1.rb lib/namespace/2.rb }
    handler = Ruby.new(files)
    handler.handle!
    
    handler.tests.should == %w{ test/1_test.rb test/2_test.rb }
    files.should == %w{ Rakefile }
  end
end