require 'optparse'

class Kicker
  class << self
    attr_accessor :latency, :paths, :silent, :quiet, :clear_console
    
    def silent?
      @silent
    end
    
    def quiet?
      @quiet
    end
    
    def clear_console?
      @clear_console
    end
    
    def has_growl?
      Kicker.const_defined?(:Growl)
    end
  end
  
  self.latency = 1
  self.paths = %w{ . }
  self.silent = false
  self.quiet = false
  self.clear_console = false
  
  module Options #:nodoc:
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
        
        opt.on('-v', 'Print the Kicker version') do
          puts VERSION
          exit
        end

        opt.on('-s', '--silent', 'Keep output to a minimum.') do |silent|
          Kicker.silent = true
        end
        
        opt.on('-q', '--quiet', "Quiet output. Don't print timestamps when logging.") do |quiet|
          Kicker.silent = Kicker.quiet = true
        end
        
        opt.on('-c', '--clear', "Clear console before each run.") do |clear|
          Kicker.clear_console = true
        end
        
        if Kicker::Growl.usable?
          opt.on('--[no-]growl', 'Whether or not to use Growl. Default is to use growl.') do |growl|
            Kicker::Growl.use = growl
          end
          
          opt.on('--growl-command [COMMAND]', 'The command to execute when the Growl succeeded message is clicked.') do |command|
            Kicker::Growl.command = command
          end
        else
          Kicker::Growl.use = false
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
  # Returns the global OptionParser instance that recipes can use to add
  # options.
  def options
    Kicker::Options.parser
  end
end
