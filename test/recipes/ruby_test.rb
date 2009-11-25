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
  before do
    Ruby.test_type = nil
    Ruby.runner_bin = nil
    Ruby.test_options = []
  end
  
  after do
    Ruby.test_type = 'test'
    Ruby.runner_bin = nil
    Ruby.test_options = []
  end
  
  it "should instantiate a Ruby instance" do
    handler = mock('Ruby', :handle! => nil, :tests => %w{ test/1_test.rb test/namespace/2_test.rb })
    Ruby.expects(:new).with(%w{ test/1_test.rb Rakefile test/namespace/2_test.rb }).returns(handler)
    Ruby.expects(:run_tests).with(%w{ test/1_test.rb test/namespace/2_test.rb })
    RUBY_FILES.call(%w{ test/1_test.rb Rakefile test/namespace/2_test.rb })
  end
  
  it "should discover whether to use `ruby' or `spec' as the test_type" do
    File.expects(:exist?).with('spec').returns(false)
    Ruby.test_type.should == 'test'
    
    Ruby.test_type = nil
    File.expects(:exist?).with('spec').returns(true)
    Ruby.test_type.should == 'spec'
  end
  
  it "should run the given tests with a test-unit runner" do
    Ruby.expects(:execute).with("ruby  -r test/1_test.rb -r test/namespace/2_test.rb -e ''")
    Ruby.run_tests(%w{ test/1_test.rb test/namespace/2_test.rb })
  end
  
  it "should run the given tests with a spec runner" do
    Ruby.stubs(:test_type).returns('spec')
    Ruby.expects(:execute).with("spec  spec/1_spec.rb spec/namespace/2_spec.rb")
    Ruby.run_tests(%w{ spec/1_spec.rb spec/namespace/2_spec.rb })
  end
  
  it "should not try to run the tests if none were given" do
    Ruby.expects(:execute).never
    Ruby.run_tests([])
  end
  
  it "should be possible to override the bin path" do
    Ruby.runner_bin = '/some/other/runner'
    Ruby.expects(:execute).with("/some/other/runner  -r test/1_test.rb -r test/namespace/2_test.rb -e ''")
    Ruby.run_tests(%w{ test/1_test.rb test/namespace/2_test.rb })
  end
  
  it "should set the alternative ruby bin path" do
    Kicker::Options.parse(%w{ -b /opt/ruby-1.9.2/bin/ruby })
    Ruby.runner_bin.should == '/opt/ruby-1.9.2/bin/ruby'
    
    Ruby.runner_bin = nil
    Kicker::Options.parse(%w{ --ruby /opt/ruby-1.9.2/bin/ruby })
    Ruby.runner_bin.should == '/opt/ruby-1.9.2/bin/ruby'
  end
  
  it "should be possible to add runner options when test_type is `test'" do
    Ruby.test_type = 'test'
    Ruby.test_options << '-I ./other'
    Ruby.expects(:execute).with("ruby -I ./other -r test/1_test.rb -e ''")
    Ruby.run_tests(%w{ test/1_test.rb })
  end
  
  it "should be possible to add runner options when test_type is `spec'" do
    Ruby.test_type = 'spec'
    Ruby.test_options << '-I ./other'
    Ruby.expects(:execute).with("spec -I ./other spec/1_spec.rb")
    Ruby.run_tests(%w{ spec/1_spec.rb })
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
      Ruby.stubs(:test_cases_root).returns(type)
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
    
    it "should check if a different test case root" do
      Ruby.stubs(:test_cases_root).returns('test/cases')
      
      files = %W{ Rakefile test/cases/1_#{type}.rb test/cases/namespace/2_#{type}.rb }
      handler = Ruby.new(files)
      handler.handle!
      
      handler.tests.should == %W{ test/cases/1_#{type}.rb test/cases/namespace/2_#{type}.rb }
      files.should == %W{ Rakefile }
    end
  end
end