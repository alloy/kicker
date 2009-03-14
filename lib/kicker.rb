$:.unshift File.expand_path('../../vendor', __FILE__)
require 'rucola/fsevents'
require 'growlnotifier/growl_helpers'
require 'optparse'

class Kicker
  OPTION_PARSER = lambda do |options|
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options] -e [command] [path]"
      
      opts.on('-e', '--execute [COMMAND]', 'The command to execute.') do |command|
        options[:command] = command
      end
      
      opts.on('--[no-]growl', 'Whether or not to use Growl. Default is to use growl.') do |growl|
        options[:growl] = growl
      end
      
      opts.on('--growl-message [MESSAGE]', 'The message to Growl when the command succeeded.') do |message|
        options[:growl_message] = message
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
    options[:path] = argv.first
    options
  end
  
  def self.run!(argv = ARGV)
    new(parse_options(argv)).start
  end
  
  include Growl
  GROWL_NOTIFICATIONS = {
    :change => 'Change occured',
    :succeeded => 'Command succeeded',
    :failed => 'Command failed'
  }
  GROWL_DEFAULT_CALLBACK = lambda do
    OSX::NSWorkspace.sharedWorkspace.launchApplication('Terminal')
  end
  
  attr_writer :command
  attr_reader :path, :file
  attr_accessor :use_growl, :growl_command
  
  def initialize(options)
    self.path      = options[:path] if options[:path]
    @command       = options[:command]
    @use_growl     = options[:growl]
    @growl_command = options[:growl_command]
  end
  
  def path=(path)
    @path = File.expand_path(path)
    @file, @path = @path, File.dirname(@path) unless File.directory?(@path)
  end
  
  def start
    validate_options!
    
    log "Watching for changes on `#{file || path}'"
    log "With command: #{command}"
    log ''
    
    watch_dog = Rucola::FSEvents.start_watching(path) { |events| process(events) }
    
    trap('INT') do
      log "Cleaning up…"
      watch_dog.stop
      exit
    end
    
    Growl::Notifier.sharedInstance.register('Kicker', Kicker::GROWL_NOTIFICATIONS.values) if @use_growl
    
    OSX.CFRunLoopRun
  end
  
  def command
    "sh -c #{@command.inspect}"
  end
  
  def process(events)
    execute! unless file && !events.find { |e| e.last_modified_file == file }
  end
  
  def log(message)
    puts "[#{Time.now}] #{message}"
  end
  
  def execute!
    log "Change occured. Executing command:"
    growl(GROWL_NOTIFICATIONS[:change], 'Kicker: Change occured', 'Executing command') if @use_growl
    
    output = `#{command}`
    output.strip.split("\n").each { |line| log "  #{line}" }
    
    log "Command #{last_command_succeeded? ? 'succeeded' : "failed (#{last_command_status})"}"
    
    if @use_growl
      if last_command_succeeded?
        callback = @growl_command.nil? ? GROWL_DEFAULT_CALLBACK : lambda { system(@growl_command) }
        growl(GROWL_NOTIFICATIONS[:succeeded], "Kicker: Command succeeded", output, &callback)
      else
        growl(GROWL_NOTIFICATIONS[:failed], "Kicker: Command failed (#{last_command_status})", output, &GROWL_DEFAULT_CALLBACK)
      end
    end
  end
  
  def last_command_succeeded?
    $?.success?
  end
  
  def last_command_status
    $?.to_i
  end
  
  def validate_options!
    validate_path_and_command!
    validate_path_exists!
  end
  
  def validate_path_and_command!
    unless @path && @command
      puts OPTION_PARSER.call(nil).help
      exit
    end
  end
  
  def validate_path_exists!
    unless File.exist?(@path)
      puts "The given path `#{@path}' does not exist"
      exit 1
    end
  end
end