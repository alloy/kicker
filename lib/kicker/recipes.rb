$:.unshift(RECIPES_DIR = File.expand_path('../recipes', __FILE__))
require 'could_not_handle_file'
require 'execute_cli_command'

USER_RECIPES_DIR = File.expand_path('~/.kick')
$:.unshift(USER_RECIPES_DIR) if File.exist?(USER_RECIPES_DIR)

class Kicker
  module Recipes
    class << self
      attr_writer :recipes_to_load
      def recipes_to_load
        @recipes_to_load ||= []
      end
      
      def load!
        load_recipes
        load_dot_kick
      end
      
      def load_dot_kick
        if File.exist?('.kick')
          require 'dot_kick'
          ReloadDotKick.save_state
          Kernel.load '.kick'
        end
      end
      
      def load_recipes
        recipes_to_load.each do |recipe|
          raise "Recipe `#{recipe}' does not exist." unless recipe_exists?(recipe)
          require recipe
        end
      end
      
      def recipe_exists?(recipe)
        File.exist?("#{RECIPES_DIR}/#{recipe}.rb") || File.exist?("#{USER_RECIPES_DIR}/#{recipe}.rb")
      end
    end
  end
end