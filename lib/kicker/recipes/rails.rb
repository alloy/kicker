process do |files|
  test_files = []
  
  files.delete_if do |file|
    # Match any ruby test file and run it
    if file =~ /^test\/.+_test\.rb$/
      test_files << file
    
    # Match any file in app/ and map it to a test file
    elsif match = file.match(%r{^app/(\w+)([\w/]*)/([\w\.]+)\.\w+$})
      type, namespace, file = match[1..3]
      
      dir = case type
      when "models"
        "unit"
      when "concerns"
        "unit/concerns"
      end
      
      if dir
        test_file = File.join("test", dir, namespace, "#{file}_test.rb")
        test_files << test_file if File.exist?(test_file)
      end
    end
  end
  
  run_ruby_tests test_files
end