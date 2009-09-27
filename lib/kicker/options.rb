require 'optparse'

class Kicker
  DONT_SHOW_RECIPES = %w{ could_not_handle_file execute_cli_command }
  
  def self.recipes_for_display
    [RECIPES_DIR, USER_RECIPES_DIR].map do |dir|
      Dir.glob("#{dir}/*.rb").map { |f| File.basename(f, '.rb') }
    end.flatten - DONT_SHOW_RECIPES
  end
  
  def self.option_parser
    @option_parser ||= OptionParser.new do |opt|
      opt.banner = "Usage: #{$0} [options] [paths to watch]"
    end
  end
  
  OPTION_PARSER_CALLBACK = lambda do |options|
    option_parser.on('--[no-]growl', 'Whether or not to use Growl. Default is to use growl.') do |growl|
      options[:growl] = growl
    end
    
    option_parser.on('--growl-command [COMMAND]', 'The command to execute when the Growl succeeded message is clicked.') do |command|
      options[:growl_command] = command
    end
    
    option_parser.on('-l', '--latency [FLOAT]', "The time to collect file change events before acting on them. Defaults to 1.5 sec.") do |latency|
      options[:latency] = Float(latency)
    end
    
    option_parser.on('-r', '--recipe [NAME]', 'A named recipe to load.') do |recipe|
      (options[:recipes] ||= []) << recipe
    end
    
    option_parser.separator " "
    option_parser.separator "  Available recipes:"
    Kicker.recipes_for_display.each { |recipe| option_parser.separator "    - #{recipe}" }
    
    option_parser
  end
  
  def self.parse_options(argv)
    argv = argv.dup
    options = { :growl => true }
    OPTION_PARSER_CALLBACK.call(options).parse!(argv)
    options[:paths] = argv unless argv.empty?
    options
  end
end