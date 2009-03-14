$:.unshift File.expand_path('../../vendor', __FILE__)
require 'rucola/fsevents'

class Kicker
  attr_writer :command
  attr_reader :path, :file
  
  def initialize(options)
    self.path = options[:path] if options[:path]
    @command = options[:command]
  end
  
  def path=(path)
    @path = File.expand_path(path)
    @file, @path = @path, File.dirname(@path) unless File.directory?(@path)
  end
  
  def start
    validate_options!
    
    log "Watching for changes on `#{file || path}'"
    log "With command: #{command}\n"
    
    watch_dog = Rucola::FSEvents.start_watching(path) { |events| process(events) }
    trap('INT') do
      watch_dog.stop
      exit
    end
  end
  
  def command
    "sh -c #{@command.inspect}"
  end
  
  def process(events)
    execute! unless file && !events.find { |e| e.last_modified_file == file }
  end
  
  private
  
  def log(message)
    puts "[#{Time.now}] #{message}"
  end
  
  def execute!
    log "Change occured. Executing command:"
    `#{command}`.strip.split("\n").each { |line| log "  #{line}" }
    log "Command #{last_command_succeeded? ? 'succeeded' : "failed (#{last_command_status})"}"
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
      puts "Usage: #{$0} [PATH] [COMMAND]"
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