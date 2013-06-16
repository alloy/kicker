recipe :ruby

class Kicker::Recipes::Rails < Kicker::Recipes::Ruby
  class << self
    # Call these options on the Ruby class which takes the cli options.
    %w{ test_type runner_bin test_cases_root test_options }.each do |delegate|
      define_method(delegate) { Kicker::Recipes::Ruby.send(delegate) }
    end

    # Maps +type+, for instance `models', to a test directory.
    def type_to_test_dir(type)
      if test_type == 'test'
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
      elsif test_type == 'spec'
        case type
        when "models"
          "models"
        when "concerns"
          "models/concerns"
        when "controllers", "views"
          "controllers"
        when "helpers"
          "helpers"
        end
      end
    end

    # Returns an array consiting of all controller tests.
    def all_controller_tests
      if test_type == 'test'
        Dir.glob("#{test_cases_root}/functional/**/*_test.rb")
      else
        Dir.glob("#{test_cases_root}/controllers/**/*_spec.rb")
      end
    end
  end

  # Returns an array of all tests related to the given model.
  def tests_for_model(model)
    if test_type == 'test'
      %W{
        unit/#{ActiveSupport::Inflector.singularize(model)}
        unit/helpers/#{ActiveSupport::Inflector.pluralize(model)}_helper
        functional/#{ActiveSupport::Inflector.pluralize(model)}_controller
      }
    else
      %W{
        models/#{ActiveSupport::Inflector.singularize(model)}
        helpers/#{ActiveSupport::Inflector.pluralize(model)}_helper
        controllers/#{ActiveSupport::Inflector.pluralize(model)}_controller
      }
    end.map { |f| test_file f }
  end

  def handle!
    @tests.concat(@files.take_and_map do |file|
      case file
      # Run all functional tests when routes.rb is saved
      when 'config/routes.rb'
        Kicker::Recipes::Rails.all_controller_tests

      # Match lib/*
      when /^(lib\/.+)\.rb$/
        test_file($1)

      # Map fixtures to their related tests
      when %r{^#{test_cases_root}/fixtures/(\w+)\.yml$}
        tests_for_model($1)

      # Match any file in app/ and map it to a test file
      when %r{^app/(\w+)([\w/]*)/([\w\.]+)\.\w+$}
        type, namespace, file = $1, $2, $3

        if dir = Kicker::Recipes::Rails.type_to_test_dir(type)
          if type == "views"
            namespace = namespace.split('/')[1..-1]
            file = "#{namespace.pop}_controller"
          end

          test_file File.join(dir, namespace, file)
        end
      end
    end)

    # And let the Ruby handler match other stuff.
    super
  end
end

recipe :rails do
  require 'rubygems' rescue LoadError
  require 'active_support/inflector'

  process Kicker::Recipes::Rails

  # When changing the schema, prepare the test database.
  process do |files|
    execute 'rake db:test:prepare' if files.delete('db/schema.rb')
  end
end
