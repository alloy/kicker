$:.unshift File.expand_path('../../vendor', __FILE__)

require 'kicker/version'
require 'kicker/fsevents'
require 'kicker/callback_chain'
require 'kicker/core_ext'
require 'kicker/growl'
require 'kicker/options'
require 'kicker/utils'
require 'kicker/recipes'

class Kicker #:nodoc:
  def self.run(argv = ARGV)
    Kicker::Options.parse(argv)
    new.start
  end
  
  attr_reader :last_event_processed_at
  
  def initialize
    finished_processing!
  end
  
  def paths
    @paths ||= Kicker.paths.map { |path| File.expand_path(path) }
  end
  
  def start
    validate_options!
    
    log "Watching for changes on: #{paths.join(', ')}"
    log ''
    
    Kicker::Growl.start! if Kicker::Growl.usable? && Kicker::Growl.use?
    run_startup_chain
    run_watch_dog!
  end
  
  private
  
  def validate_options!
    validate_paths_and_command!
    validate_paths_exist!
  end
  
  def validate_paths_and_command!
    if startup_chain.empty? && process_chain.empty? && pre_process_chain.empty?
      puts Kicker::Options.parser.help
      exit
    end
  end
  
  def validate_paths_exist!
    paths.each do |path|
      unless File.exist?(path)
        puts "The given path `#{path}' does not exist"
        exit 1
      end
    end
  end
  
  def run_watch_dog!
    dirs = @paths.map { |path| File.directory?(path) ? path : File.dirname(path) }
    watch_dog = Kicker::FSEvents.start_watching(dirs, :latency => self.class.latency) do |events|
      process events
    end
    
    trap('INT') do
      log "Exiting ..."
      watch_dog.stop
      exit
    end

    wait_for_threads
  end

  def wait_for_threads
    (Thread.list - [Thread.current]).each(&:join)
  end

  def run_startup_chain
    startup_chain.call([], false)
  end
  
  def finished_processing!
    @last_event_processed_at = Time.now
  end
  
  def process(events)
    unless (files = changed_files(events)).empty?
      Utils.should_clear_screen = true
      full_chain.call(files)
      finished_processing!
    end
  end
  
  def changed_files(events)
    make_paths_relative(events.map do |event|
      files_in_directory(event.path).select { |file| file_changed_since_last_event? file }
    end.flatten.uniq.sort)
  end
  
  def files_in_directory(dir)
    Dir.entries(dir).sort[2..-1].map { |f| File.join(dir, f) }
  rescue Errno::ENOENT
    []
  end
  
  def file_changed_since_last_event?(file)
    File.mtime(file) > @last_event_processed_at
  rescue Errno::ENOENT
    false
  end
  
  def make_paths_relative(files)
    return files if files.empty?
    wd = Dir.pwd
    files.map do |file|
      if file[0..wd.length-1] == wd
        file[wd.length+1..-1]
      else
        file
      end
    end
  end
end
