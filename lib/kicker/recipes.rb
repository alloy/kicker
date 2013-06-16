module Kernel
  # If only given a <tt>name</tt>, the specified recipe will be loaded. For
  # instance, the following, in a <tt>.kick</tt> file, will load the Rails
  # recipe:
  #
  #   recipe :rails
  #
  # However, this same method is used to define a callback that is called _if_
  # the recipe is loaded. For instance, the following, in a recipe file, will
  # be called if the recipe is actually used:
  #
  #   recipe :rails do
  #     # Load anything needed for the recipe.
  #     process do
  #       # ...
  #     end
  #   end
  def recipe(name, &block)
    Kicker::Recipes.recipe(name, &block)
  end
end

class Kicker
  module Recipes #:nodoc:
    RECIPES_DIR      = Pathname.new('../recipes').expand_path(__FILE__)
    USER_RECIPES_DIR = Pathname.new('~/.kick').expand_path
    CURRENT_RECIPES_DIR = Pathname.pwd.join('.kick').expand_path

    RECIPES_DIRS = [RECIPES_DIR, USER_RECIPES_DIR, CURRENT_RECIPES_DIR]

    class << self
      def reset!
        @recipes = nil
        # Always load all the base recipes
        load_recipe :execute_cli_command
        load_recipe :could_not_handle_file
        load_recipe :dot_kick
      end

      def recipes
        @recipes ||= {}
      end

      def recipe_filename(name)
        [
          USER_RECIPES_DIR,
          RECIPES_DIR
        ].each do |directory|
          filename = directory.join("#{name}.rb")
          return filename if filename.exist?
        end
      end

      def recipe_names
        recipe_files.map { |filename| filename.basename('.rb').to_s.to_sym }
      end

      def recipe_files
        RECIPES_DIRS.map{|dir| Pathname.glob(dir.join('*.rb')) }.flatten.uniq.map(&:expand_path)
      end

      def define_recipe(name, &block)
        recipes[name] = block
      end

      def load_recipe(name)
        if recipe_names.include?(name)
          load recipe_filename(name)
        else
          raise LoadError, "Can't load recipe `#{name}', it doesn't exist on disk. Loadable recipes are: #{recipe_names[0..-2].join(', ')}, and #{recipe_names[-1]}"
        end
      end

      def activate_recipe(name)
        unless recipes.has_key?(name)
          load_recipe(name)
        end
        if recipe = recipes[name]
          recipe.call
        else
          raise ArgumentError, "Can't activate the recipe `#{name}' because it hasn't been defined yet."
        end
      end

      # See Kernel#recipe for more information about the usage.
      def recipe(name, &block)
        name = name.to_sym
        if block_given?
          define_recipe(name, &block)
        else
          activate_recipe(name)
        end
      end
    end

    reset!
  end
end
