require 'kicker/recipes/base'

class Kicker
  module Recipes
    class RubyTestRunner < Base
      def test_files
        @test_files ||= []
      end
      
      def handle!
        run_tests
      end
      
      def run_tests
        Kicker.execute_command("ruby -r #{test_files.join(' -r ')} -e ''") unless test_files.empty?
      end
    end
  end
end