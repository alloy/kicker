process do |files|
  test_files = []
  
  files.delete_if do |file|
    case file
    when %r{^test/javascripts/(\w+)_test\.(js|html)$}
    when %r{^public/javascripts/(\w+)\.js$}
    else
      next
    end
    test_files << "test/javascripts/#{$1}_test.html"
  end
  
  execute "jstest #{test_files.join(' ')}" unless test_files.empty?
end