require 'optparse'

class Kicker
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
    
    option_parser.on('-l', '--latency [FLOAT]', 'FSEvent grouping latency') do |latency|
      options[:latency] = Float(latency)
    end
    
    option_parser
  end
  
  def self.parse_options(argv)
    argv = argv.dup
    options = { :growl => true }
    OPTION_PARSER_CALLBACK.call(options).parse!(argv)
    options[:paths] = argv
    options
  end
end