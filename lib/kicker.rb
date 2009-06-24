$:.unshift File.expand_path('../../vendor', __FILE__)
require 'rucola/fsevents'
require 'kicker/callback_chain'
require 'kicker/growl'
require 'kicker/options'
require 'kicker/utils'
require 'kicker/validate'

require 'kicker/recipes/execute_cli_command'

class Kicker
  def self.paths
    @paths ||= %w{ . }
  end
  
  def self.run(argv = ARGV)
    new(parse_options(argv)).start
  end
  
  attr_reader :paths, :last_event_processed_at
  
  def initialize(options)
    @paths = (options[:paths] ? options[:paths] : Kicker.paths).map { |path| File.expand_path(path) }
    @last_event_processed_at = Time.now
    
    @use_growl     = options[:growl]
    @growl_command = options[:growl_command]
  end
  
  def callback_chain
    self.class.callback_chain
  end
  
  def start
    validate_options!
    
    log "Watching for changes on: #{@paths.join(', ')}"
    log ''
    
    run_watch_dog!
    start_growl! if @use_growl
    
    OSX.CFRunLoopRun
  end
  
  private
  
  def run_watch_dog!
    dirs = @paths.map { |path| File.directory?(path) ? path : File.dirname(path) }
    watch_dog = Rucola::FSEvents.start_watching(*dirs) { |events| process(events) }
    
    trap('INT') do
      log "Cleaning up…"
      watch_dog.stop
      exit
    end
  end
  
  def finished_processing!
    @last_event_processed_at = Time.now
  end
  
  def changed_files(events)
    events.map do |event|
      event.files.select { |file| File.mtime(file) > @last_event_processed_at }
    end.flatten
  end
  
  def process(events)
    unless (files = changed_files(events)).empty?
      callback_chain.run(self, files)
      finished_processing!
    end
  end
end