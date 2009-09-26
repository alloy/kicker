class Kicker
  module Recipes
    class Base
      class NotImplementedError < StandardError; end
      
      def self.call(files)
        new(files).handle!
      end
      
      attr_reader :files
      
      def initialize(files)
        @files = files
        after_initialize if respond_to?(:after_initialize)
      end
      
      def handle!
        raise NotImplementedError, 'The subclass should implement this method to handle the changed files.'
      end
    end
  end
end