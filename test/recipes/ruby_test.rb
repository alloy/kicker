require File.expand_path('../../test_helper', __FILE__)
recipe :ruby

class Kicker::Recipes::Ruby
  class << self
    attr_accessor :executed
    attr_accessor :blocks
    def execute(command, &block)
      self.executed ||= []
      self.blocks ||= []
      
      self.executed << command
      self.blocks << block
    end
  end
end

describe "The Ruby handler" do
  before do
    @handler = Kicker::Recipes::Ruby
    @handler.reset!
  end
  
  after do
    File.use_original_exist = true
  end
  
  it "should instantiate a handler instance when called" do
    tests = %w{ test/1_test.rb Rakefile test/namespace/2_test.rb }
    instance = @handler.new(tests)
    @handler.expects(:new).with(tests).returns(instance)
    @handler.call(tests)
  end
  
  it "should discover whether to use `ruby' or `spec' as the test_type" do
    File.use_original_exist = false
    
    File.existing_files = []
    @handler.test_type.should == 'test'
    
    @handler.reset!
    
    File.existing_files = ['spec']
    @handler.test_type.should == 'spec'
  end
  
  it "should run the given tests with a test-unit runner" do
    @handler.run_tests(%w{ test/1_test.rb test/namespace/2_test.rb })
    @handler.executed.last.should == "ruby -r test/1_test.rb -r test/namespace/2_test.rb -e ''"
  end
  
  it "should run the given tests with a spec runner" do
    @handler.test_type = 'spec'
    @handler.run_tests(%w{ test/1_test.rb test/namespace/2_test.rb })
    @handler.executed.last.should == "rspec test/1_test.rb test/namespace/2_test.rb"
  end
  
  it "should not try to run the tests if none were given" do
    @handler.executed = []
    @handler.run_tests([])
    @handler.executed.should.be.empty
  end
  
  it "should be possible to override the bin path" do
    @handler.runner_bin = '/some/other/runner'
    @handler.run_tests(%w{ test/1_test.rb test/namespace/2_test.rb })
    @handler.executed.last.should == "/some/other/runner -r test/1_test.rb -r test/namespace/2_test.rb -e ''"
  end
  
  it "should set the alternative ruby bin path" do
    Kicker::Options.parse(%w{ -b /opt/ruby-1.9.2/bin/ruby })
    @handler.runner_bin.should == '/opt/ruby-1.9.2/bin/ruby'
    
    @handler.reset!
    
    Kicker::Options.parse(%w{ --ruby /opt/ruby-1.9.2/bin/ruby })
    @handler.runner_bin.should == '/opt/ruby-1.9.2/bin/ruby'
  end
  
  it "should be possible to add runner options when test_type is `test'" do
    @handler.test_type = 'test'
    @handler.test_options << '-I ./other'
    @handler.run_tests(%w{ test/1_test.rb })
    @handler.executed.last.should == "ruby -I ./other -r test/1_test.rb -e ''"
  end
  
  it "should be possible to add runner options when test_type is `spec'" do
    @handler.test_type = 'spec'
    @handler.test_options << '-I ./other'
    @handler.run_tests(%w{ spec/1_spec.rb })
    @handler.executed.last.should == "rspec -I ./other spec/1_spec.rb"
  end
  
  it "should only show the last line of the output when growling when running test_type is `test'" do
    @handler.run_with_test_runner(%w{ test/1_test.rb test/namespace/2_test.rb })
    result = @handler.blocks.last.call(mock('status', :output => "foo\nall pass", :after? => true, :growl? => true))
    result.should == 'all pass'
  end
  
  it "should only show the last line of the output when growling when running test_type is `spec'" do
    @handler.run_with_spec_runner(%w{ spec/1_spec.rb spec/namespace/2_spec.rb })
    result = @handler.blocks.last.call(mock('status', :output => "foo\nall pass", :after? => true, :growl? => true))
    result.should == 'all pass'
  end
end

%w{ test spec }.each do |type|
  describe "An instance of the Ruby handler, with test type `#{type}'" do
    before do
      @handler = Kicker::Recipes::Ruby
      @handler.test_type = type
      @handler.test_cases_root = type
      
      File.use_original_exist = false
      File.existing_files = %W(#{type}/1_#{type}.rb #{type}/namespace/2_#{type}.rb)
    end
    
    after do
      File.use_original_exist = true
    end
    
    it "should match any test case files" do
      files = %w(Rakefile) + File.existing_files
      handler = @handler.new(files)
      handler.handle!
      
      handler.tests.should == File.existing_files
      files.should == %W{ Rakefile }
    end
    
    it "should match files in ./lib" do
      files = %w(Rakefile) + File.existing_files
      handler = @handler.new(files)
      handler.handle!
      
      handler.tests.should == File.existing_files
      files.should == %w{ Rakefile }
    end
    
    it "should match lib tests in the test root as well" do
      File.existing_files = %W(#{type}/1_#{type}.rb #{type}/2_#{type}.rb)
      
      files = %W{ Rakefile lib/1.rb lib/namespace/2.rb }
      handler = @handler.new(files)
      handler.handle!
      
      handler.tests.should == %W{ #{type}/1_#{type}.rb #{type}/2_#{type}.rb }
      files.should == %W{ Rakefile }
    end
    
    it "should check if a different test case root" do
      @handler.test_cases_root = 'test/cases'
      
      files = %W{ Rakefile test/cases/1_#{type}.rb test/cases/namespace/2_#{type}.rb }
      handler = @handler.new(files)
      handler.handle!
      
      handler.tests.should == %W{ test/cases/1_#{type}.rb test/cases/namespace/2_#{type}.rb }
      files.should == %W{ Rakefile }
    end
  end
end