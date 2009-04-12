$:.unshift File.expand_path('../../vendor', __FILE__)
require 'rucola/fsevents'
require 'growlnotifier/growl_helpers'
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
  attr_reader :paths
  attr_accessor :use_growl, :growl_command
  
  def initialize(options)
    @paths         = options[:paths].map { |path| File.expand_path(path) }
    @command       = options[:command]
    @use_growl     = options[:growl]
    @growl_command = options[:growl_command]
  end
  
  def start
    validate_options!
    
    log "Watching for changes on: #{@paths.join(', ')}"
    log "With command: #{command}"
    log ''
    
    dirs = @paths.map { |path| File.directory?(path) ? path : File.dirname(path) }
    watch_dog = Rucola::FSEvents.start_watching(*dirs) { |events| process(events) }
    
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
    events.each do |event|
      @paths.each do |path|
        return execute! if event.last_modified_file =~ /^#{path}/
      end
    end
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
    validate_paths_and_command!
    validate_paths_exist!
  end
  
  def validate_paths_and_command!
    if @paths.empty? && @command.nil?
      puts OPTION_PARSER.call(nil).help
      exit
    end
  end
  
  def validate_paths_exist!
    @paths.each do |path|
      unless File.exist?(path)
        puts "The given path `#{path}' does not exist"
        exit 1
      end
    end
  end
end