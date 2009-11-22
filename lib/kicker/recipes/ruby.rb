class Ruby
  def self.call(files)
    handler = new(files)
    handler.handle!
    handler.run_tests
  end
  
  attr_reader :tests
  
  def initialize(files)
    @files = files
    @tests = []
  end
  
  def test_type
    'test'
  end
  
  def runner_bin
    test_type == 'test' ? 'ruby' : 'spec'
  end
  
  # Returns the file for +name+ if it exists.
  #
  #   test_file('foo') # => "test/foo_test.rb"
  #   test_file('foo/bar') # => "test/foo/bar_test.rb"
  #   test_file('does/not/exist') # => nil
  def test_file(name)
    file = File.join(test_type, "#{name}_#{test_type}.rb")
    file if File.exist?(file)
  end
  
  def handle!
    @tests.concat(@files.take_and_map do |file|
      case file
      # Match any ruby test file
      when /^#{test_type}\/.+_#{test_type}\.rb$/
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
  
  def run_tests
    send("run_with_#{test_type}_runner") unless @tests.empty?
  end
  
  def run_with_test_runner
    execute "#{runner_bin} -r #{@tests.join(' -r ')} -e ''"
  end
  
  def run_with_spec_runner
    execute "#{runner_bin} #{@tests.join(' ')}"
  end
end

process Ruby