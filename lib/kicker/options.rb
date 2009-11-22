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
      return [] unless defined?(USER_RECIPES_DIR)
      [RECIPES_DIR, USER_RECIPES_DIR].map do |dir|
        Dir.glob("#{dir}/*.rb").map { |f| File.basename(f, '.rb') }
      end.flatten - DONT_SHOW_RECIPES
    end
    
    def self.parser
      @parser ||= OptionParser.new do |opt|
        opt.banner = "Usage: #{$0} [options] [paths to watch]"
        
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
        
        opt.on('-b', '--ruby [PATH]', "Use an alternate Ruby binary for spawned tasks. (Default is `#{Kicker::Utils.ruby_bin_path}')") do |path|
          Kicker::Utils.ruby_bin_path = path
        end
        
        opt.on('-r', '--recipe [NAME]', 'A named recipe to load.') do |recipe|
          Kicker::Recipes.recipes_to_load << recipe
        end
      end
      
      # This is needed, because recipes might add options, in which case we don't have to add this yet.
      unless @added_recipes_to_banner || recipes_for_display.empty?
        @parser.separator " "
        @parser.separator "  Available recipes:"
        recipes_for_display.each { |recipe| @parser.separator "    - #{recipe}" }
        @added_recipes_to_banner = true
      end
      
      @parser
    end
    
    def self.parse(argv)
      parser.parse!(argv)
      Kicker.paths = argv unless argv.empty?
    end
  end
end