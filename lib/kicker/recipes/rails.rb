require 'kicker/recipes/base'

class Kicker
  module Recipes
    class Rails < Base
      attr_reader :test_files
      
      def after_initialize
        @test_files = []
      end
      
      def handle!
        @files.delete_if do |full_path|
          path = relative_path(full_path)
          
          # Match any ruby test file and run it
          if path =~ /^test\/.+_test\.rb$/
            @test_files << path
          end
        end
        
        run_tests
      end
      
      def run_tests
        Kicker.execute_command("ruby -r #{@test_files.join(' -r ')} -e ''")
      end
    end
  end
end