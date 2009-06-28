class Kicker
  module Recipes
    class Base
      class NotImplementedError < StandardError; end
      
      def self.call(kicker, files)
        new(kicker, files).handle!
      end
      
      attr_reader :kicker, :files
      
      def initialize(kicker, files)
        @kicker, @files = kicker, files
        after_initialize if respond_to?(:after_initialize)
      end
      
      def handle!
        raise NotImplementedError, 'The subclass should implement this method to handle the changed files.'
      end
      
      def relative_path(path)
        path[(Dir.pwd.length + 1)..-1]
      end
    end
  end
end