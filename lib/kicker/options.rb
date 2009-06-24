require 'optparse'

class Kicker
  OPTION_PARSER = lambda do |options|
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options] -e [command] [paths to watch]"
      
      opts.on('-e', '--execute [COMMAND]', 'The command to execute.') do |command|
        options[:command] = command
      end
      
      opts.on('--[no-]growl', 'Whether or not to use Growl. Default is to use growl.') do |growl|
        options[:growl] = growl
      end
      
      opts.on('--growl-command [COMMAND]', 'The command to execute when the Growl succeeded message is clicked.') do |command|
        options[:growl_command] = command
      end
    end
  end
  
  def self.parse_options(argv)
    argv = argv.dup
    options = { :growl => true }
    OPTION_PARSER.call(options).parse!(argv)
    options[:paths] = argv
    options
  end
end