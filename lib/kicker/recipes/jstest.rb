recipe :jstest do
  process do |files|
    test_files = files.take_and_map do |file|
      if file =~ %r{^(test|public)/javascripts/(\w+?)(_test)*\.(js|html)$}
        "test/javascripts/#{$2}_test.html"
      end
    end
    execute "jstest #{test_files.join(' ')}" unless test_files.empty?
  end
end
