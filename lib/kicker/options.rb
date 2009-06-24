require 'optparse'

class Kicker
  PARSER = OptionParser.new do |opt|
    opt.banner = "Usage: #{$0} [options] -e [command] [paths to watch]"
  end
  
  OPTION_PARSER = lambda do |options|
    PARSER.on('--[no-]growl', 'Whether or not to use Growl. Default is to use growl.') do |growl|
      options[:growl] = growl
    end
    
    PARSER.on('--growl-command [COMMAND]', 'The command to execute when the Growl succeeded message is clicked.') do |command|
      options[:growl_command] = command
    end
    
    PARSER
  end
  
  def self.parse_options(argv)
    argv = argv.dup
    options = { :growl => true }
    OPTION_PARSER.call(options).parse!(argv)
    options[:paths] = argv
    options
  end
end