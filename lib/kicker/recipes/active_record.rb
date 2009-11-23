require "ruby"

Ruby.test_cases_root = 'test/cases'
Ruby.test_options << "-I ./test -I ./test/connections/native_mysql"