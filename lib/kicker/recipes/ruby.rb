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
  
  def ruby_bin_path
    'ruby'
  end
  
  def test_type
    'test'
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
  
  # Needs different runners depending on the test_type. Eg spec.
  def run_tests
    execute "#{ruby_bin_path} -r #{@tests.join(' -r ')} -e ''" unless @tests.empty?
  end
end

process Ruby