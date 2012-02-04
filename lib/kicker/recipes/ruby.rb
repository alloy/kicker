class Kicker::Recipes::Ruby
  class << self
    # Assigns the type of tests to run. Eg: `test' or `spec'.
    attr_writer :test_type
    
    # Returns the type of tests to run. Eg: `test' or `spec'.
    #
    # Defaults to `test' if no `spec' directory exists.
    def test_type
      @test_type ||= File.exist?('spec') ? 'spec' : 'test'
    end
    
    # Assigns the ruby command to run the tests with. Eg: `ruby19' or `specrb'.
    #
    # This can be set from the command line with the `-b' or `--ruby' options.
    attr_writer :runner_bin
    
    # Returns the ruby command to run the tests with. Eg: `ruby' or `spec'.
    #
    # Defaults to `ruby' if test_type is `test' and `spec' if test_type is
    # `spec'.
    def runner_bin
      @runner_bin ||= test_type == 'test' ? 'ruby' : 'rspec'
    end
    
    # Assigns the root directory of where test cases will be looked up.
    attr_writer :test_cases_root
    
    # Returns the root directory of where test cases will be looked up.
    #
    # Defaults to the value of test_type. Eg: `test' or `spec'.
    def test_cases_root
      @test_cases_root ||= test_type
    end
    
    attr_writer :test_options #:nodoc:
    
    # Assigns extra options that are to be passed on to the runner_bin.
    #
    #   Ruby.test_options << '-I ./lib/foo'
    def test_options
      @test_options ||= []
    end
    
    def reset!
      @test_type = nil
      @runner_bin = nil
      @test_cases_root = nil
      @test_options = nil
    end
    
    def runner_command(*parts)
      parts.map do |part|
        case part
        when Array
          part.empty? ? nil : part.join(' ')
        else
          part.to_s
        end
      end.compact.join(' ')
    end
    
    # Runs the given tests, if there are any, with the method defined by
    # test_type. If test_type is `test' the run_with_test_runner method is
    # used. The same applies when test_type is `spec'.
    def run_tests(tests)
      send("run_with_#{test_type}_runner", tests) unless tests.empty?
    end
    
    def test_runner_command(tests)
      tests_without_ext = tests.map { |f| f[0,f.size-3] }
      runner_command(runner_bin, %w{ -I. } + test_options, '-r', tests_without_ext.join(' -r '), "-e ''")
    end
    
    # Runs the given tests with `ruby' as unit-test tests.
    #
    # If you want to adjust the logging, stdout and growl, override this, call
    # test_runner_command with the tests to get the command and call execute
    # with the custom logging block.
    def run_with_test_runner(tests)
      execute(test_runner_command(tests)) do |status|
        if status.after? && status.growl?
          status.output.split("\n").last
        end
      end
    end
    
    def spec_runner_command(tests)
      runner_command(runner_bin, test_options, tests)
    end
    
    # Runs the given tests with `spec' as RSpec tests.
    #
    # If you want to adjust the logging, stdout and growl, override this, call
    # spec_runner_command with the tests to get the command and call execute
    # with the custom logging block.
    def run_with_spec_runner(tests)
      execute(spec_runner_command(tests)) do |status|
        if status.after? && status.growl?
          status.output.split("\n").last
        end
      end
    end
  end
  
  def self.call(files) #:nodoc:
    handler = new(files)
    handler.handle!
    run_tests(handler.tests)
  end
  
  # The list of collected tests.
  attr_reader :tests
  
  def initialize(files) #:nodoc:
    @files = files
    @tests = []
  end
  
  # A shortcut to Ruby.test_type.
  def test_type
    self.class.test_type
  end
  
  # A shortcut to Ruby.runner_bin.
  def runner_bin
    self.class.runner_bin
  end
  
  # A shortcut to Ruby.test_cases_root.
  def test_cases_root
    self.class.test_cases_root
  end
  
  # Returns the file for +name+ if it exists.
  #
  #   test_file('foo') # => "test/foo_test.rb"
  #   test_file('foo/bar') # => "test/foo/bar_test.rb"
  #   test_file('does/not/exist') # => nil
  def test_file(name)
    file = File.join(test_cases_root, "#{name}_#{test_type}.rb")
    file if File.exist?(file)
  end
  
  # This method is called to collect tests. Override this if you're subclassing
  # and make sure to call +super+.
  def handle!
    @tests.concat(@files.take_and_map do |file|
      case file
      # Match any ruby test file
      when /^#{test_cases_root}\/.+_#{test_type}\.rb$/
        file
      
      # A file such as ./lib/namespace/foo.rb is mapped to:
      # * ./test/namespace/foo_test.rb
      # * ./test/foo_test.rb
      when /^lib\/(.+)\.rb$/
        if namespaced = test_file($1)
          namespaced
        elsif in_test_root = test_file(File.basename(file, '.rb'))
          in_test_root
        end
      end
    end)
  end
end

options.on('-b', '--ruby [PATH]', "Use an alternate Ruby binary for spawned test runners. (Default is `ruby')") do |command|
  Kicker::Recipes::Ruby.runner_bin = command
end

recipe :ruby do
  process Kicker::Recipes::Ruby
end
