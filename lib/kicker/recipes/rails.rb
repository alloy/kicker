process do |files|
  test_files = []
  
  files.delete_if do |file|
    # Match any ruby test file and run it
    if file =~ /^test\/.+_test\.rb$/
      test_files << file
    end
  end
  
  run_ruby_tests test_files
end