recipe :rails do
# Need to define these modules, because AS breaks if these aren't defined. Need to fix that in AS...
module ActiveSupport
  module CoreExtensions
    module String
      module Inflections
      end
    end
  end
end
require 'active_support/core_ext/string'

module Rails
  # Maps +type+, for instance `models', to a test directory.
  def self.type_to_test_dir(type)
    case type
    when "models"
      "unit"
    when "concerns"
      "unit/concerns"
    when "controllers", "views"
      "functional"
    when "helpers"
      "unit/helpers"
    end
  end
  
  # Returns an array consiting of all functional tests.
  def self.all_functional_tests
    Dir.glob("test/functional/**/*_test.rb")
  end
  
  # Returns an array of all tests related to the given model.
  def self.tests_for_model(model)
    %W{
      test/unit/#{model.singularize}_test.rb
      test/unit/helpers/#{model.pluralize}_helper_test.rb
      test/functional/#{model.pluralize}_controller_test.rb
    }
  end
end

process do |files|
  test_files = files.take_and_map do |file|
    case file
    # Match any ruby test file and run it
    when /^test\/.+_test\.rb$/
      file
    
    # Run all functional tests when routes.rb is saved
    when 'config/routes.rb'
      Rails.all_functional_tests
    
    # Match lib/*
    when /^(lib\/.+)\.rb$/
      "test/#{$1}_test.rb"
    
    # Map fixtures to their related tests
    when %r{^test/fixtures/(\w+)\.yml$}
      Rails.tests_for_model($1)
    
    # Match any file in app/ and map it to a test file
    when %r{^app/(\w+)([\w/]*)/([\w\.]+)\.\w+$}
      type, namespace, file = $1, $2, $3
      
      if dir = Rails.type_to_test_dir(type)
        if type == "views"
          namespace = namespace.split('/')[1..-1]
          file = "#{namespace.pop}_controller"
        end
        
        test_file = File.join("test", dir, namespace, "#{file}_test.rb")
        test_file if File.exist?(test_file)
      end
    end
  end
  
  run_ruby_tests test_files
end

# When changing the schema, prepare the test database.
process do |files|
  execute 'rake db:test:prepare' if files.delete('db/schema.rb')
end
end