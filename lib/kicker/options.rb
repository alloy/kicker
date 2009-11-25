require 'optparse'

class Kicker
  class << self
    attr_accessor :latency, :paths, :silent
    
    def silent?
      @silent
    end
  end
  
  self.latency = 1
  self.paths = %w{ . }
  self.silent = false
  
  module Options
    DONT_SHOW_RECIPES = %w{ could_not_handle_file execute_cli_command dot_kick }
    
    def self.recipes_for_display
      Kicker::Recipes.recipe_files.map { |f| File.basename(f, '.rb') } - DONT_SHOW_RECIPES
    end
    
    def self.parser
      @parser ||= OptionParser.new do |opt|
        opt.banner =  "Usage: #{$0} [options] [paths to watch]"
        opt.separator " "
        opt.separator "  Available recipes: #{recipes_for_display.join(", ")}."
        opt.separator " "
        
        opt.on('-s', '--silent', 'Keep output to a minimum.') do |silent|
          Kicker.silent = silent
        end
        
        opt.on('--[no-]growl', 'Whether or not to use Growl. Default is to use growl.') do |growl|
          Kicker::Growl.use = growl
        end
        
        opt.on('--growl-command [COMMAND]', 'The command to execute when the Growl succeeded message is clicked.') do |command|
          Kicker::Growl.command = command
        end
        
        opt.on('-l', '--latency [FLOAT]', "The time to collect file change events before acting on them. Defaults to #{Kicker.latency} second.") do |latency|
          Kicker.latency = Float(latency)
        end
        
        opt.on('-r', '--recipe [NAME]', 'A named recipe to load.') do |name|
          recipe(name)
        end
      end
    end
    
    def self.parse(argv)
      parser.parse!(argv)
      Kicker.paths = argv unless argv.empty?
    end
  end
end

module Kernel
  def options
    Kicker::Options.parser
  end
end