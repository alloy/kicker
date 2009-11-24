require File.expand_path('../../test_helper', __FILE__)

before = Kicker.process_chain.dup
recipe :ruby
RUBY_FILES = (Kicker.process_chain - before).first

class Ruby
  def self.execute(command, &block)
    @block = block
  end
  
  def self.execute_block
    @block
  end
end

describe "The Ruby handler" do
  it "should instantiate a Ruby instance" do
    handler = mock('Ruby', :handle! => nil, :tests => %w{ test/1_test.rb test/namespace/2_test.rb })
    Ruby.expects(:new).with(%w{ test/1_test.rb Rakefile test/namespace/2_test.rb }).returns(handler)
    Ruby.expects(:run_tests).with(%w{ test/1_test.rb test/namespace/2_test.rb })
    RUBY_FILES.call(%w{ test/1_test.rb Rakefile test/namespace/2_test.rb })
  end
  
  it "should discover whether to use `ruby' or `spec' as the test_type" do
    begin
      Ruby.test_type = nil
      File.expects(:exist?).with('spec').returns(false)
      Ruby.test_type.should == 'test'
      
      Ruby.test_type = nil
      File.expects(:exist?).with('spec').returns(true)
      Ruby.test_type.should == 'spec'
    ensure
      Ruby.test_type = 'test'
    end
  end
  
  it "should run the given tests with a test-unit runner" do
    Ruby.expects(:execute).with("ruby -r test/1_test.rb -r test/namespace/2_test.rb -e ''")
    Ruby.run_tests(%w{ test/1_test.rb test/namespace/2_test.rb })
  end
  
  it "should run the given tests with a spec runner" do
    begin
      Ruby.runner_bin = nil
      Ruby.stubs(:test_type).returns('spec')
      Ruby.expects(:execute).with("spec spec/1_spec.rb spec/namespace/2_spec.rb")
      Ruby.run_tests(%w{ spec/1_spec.rb spec/namespace/2_spec.rb })
    ensure
      Ruby.runner_bin = nil
    end
  end
  
  it "should not try to run the tests if none were given" do
    Ruby.expects(:execute).never
    Ruby.run_tests([])
  end
  
  it "should be possible to override the bin path" do
    begin
      Ruby.runner_bin = '/some/other/runner'
      Ruby.expects(:execute).with("/some/other/runner -r test/1_test.rb -r test/namespace/2_test.rb -e ''")
      Ruby.run_tests(%w{ test/1_test.rb test/namespace/2_test.rb })
    ensure
      Ruby.runner_bin = nil
    end
  end
  
  it "should only show the last line of the output when growling when running test_type is `test'" do
    Ruby.run_with_test_runner(%w{ test/1_test.rb test/namespace/2_test.rb })
    result = Ruby.execute_block.call(mock('status', :output => "foo\nall pass", :after? => true, :growl? => true))
    result.should == 'all pass'
  end
  
  it "should only show the last line of the output when growling when running test_type is `spec'" do
    Ruby.run_with_spec_runner(%w{ spec/1_spec.rb spec/namespace/2_spec.rb })
    result = Ruby.execute_block.call(mock('status', :output => "foo\nall pass", :after? => true, :growl? => true))
    result.should == 'all pass'
  end
end

%w{ test spec }.each do |type|
  describe "An instance of the Ruby handler, with test type `#{type}'" do
    before do
      Ruby.stubs(:test_type).returns(type)
      File.stubs(:exist?).with("#{type}/1_#{type}.rb").returns(true)
      File.stubs(:exist?).with("#{type}/namespace/2_#{type}.rb").returns(true)
    end
    
    it "should match any test case files" do
      files = %W{ Rakefile #{type}/1_#{type}.rb #{type}/namespace/2_#{type}.rb }
      handler = Ruby.new(files)
      handler.handle!
      
      handler.tests.should == %W{ #{type}/1_#{type}.rb #{type}/namespace/2_#{type}.rb }
      files.should == %W{ Rakefile }
    end
    
    it "should match files in ./lib" do
      files = %W{ Rakefile lib/1.rb lib/namespace/2.rb }
      handler = Ruby.new(files)
      handler.handle!
      
      handler.tests.should == %W{ #{type}/1_#{type}.rb #{type}/namespace/2_#{type}.rb }
      files.should == %w{ Rakefile }
    end
    
    it "should match lib tests in the test root as well" do
      File.stubs(:exist?).with("#{type}/namespace/2_#{type}.rb").returns(false)
      File.stubs(:exist?).with("#{type}/2_#{type}.rb").returns(true)
      
      files = %W{ Rakefile lib/1.rb lib/namespace/2.rb }
      handler = Ruby.new(files)
      handler.handle!
      
      handler.tests.should == %W{ #{type}/1_#{type}.rb #{type}/2_#{type}.rb }
      files.should == %W{ Rakefile }
    end
  end
end