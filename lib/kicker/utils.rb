require 'shellwords' if RUBY_VERSION >= "1.9"

class Kicker
  Status = Struct.new(:command, :exit_code, :output) do
    def success?
      exit_code == 0
    end
  end

  module Utils #:nodoc:
    extend self

    attr_accessor :should_clear_screen
    alias_method :should_clear_screen?, :should_clear_screen

    def perform_work(command)
      @last_command = command
      status = Status.new(command, 0, '')
      will_execute_command(status)
      yield status
      did_execute_command(status)
      status
    end

    def execute(command)
      perform_work(command) do |status|
        _execute(status)
        yield status if block_given?
      end
    end

    def last_command
      @last_command
    end

    def log(message)
      if Kicker.quiet
        puts message
      else
        now = Time.now
        puts "#{now.strftime('%H:%M:%S')}.#{now.usec.to_s[0,2]} | #{message}"
      end
    end
    
    def last_command_succeeded?
      $?.success?
    end
    
    def last_command_status
      $?.exitstatus
    end

    def clear_console!
      puts(CLEAR) if Kicker.clear_console?
    end

    private

    CLEAR = "\e[H\e[2J"

    def _execute(status)
      silent = Kicker.silent?
      unless silent
        puts
        sync_before, $stdout.sync = $stdout.sync, true
      end
      output = ""
      popen(status.command) do |io|
        while str = io.read(1)
          output << str
          $stdout.print str unless silent
        end
      end
      status.output = output.strip
      status.exit_code = last_command_status
      status
    ensure
      unless silent
        $stdout.sync = sync_before
        puts("\n\n")
      end
    end

    def popen(command, &block)
      if RUBY_VERSION >= "1.9"
        args = Shellwords.shellsplit(command)
        args << { :err => [:child, :out] }
        IO.popen(args, &block)
      else
        IO.popen("#{command} 2>&1", &block)
      end
    end
    
    def will_execute_command(status)
      puts(CLEAR) if Kicker.clear_console? && should_clear_screen?
      @should_clear_screen = false

      log "Executing: #{status.command}"
      Kicker::Growl.change_occured(status) if Kicker::Growl.use? && !Kicker.silent?
    end
    
    def did_execute_command(status)
      puts("\n#{status.output}\n\n") if Kicker.silent? && !status.success?
      log(status.success? ? "Success" : "Failed (#{status.exit_code})")
      Kicker::Growl.result(status) if Kicker::Growl.use?
    end
  end
end

module Kernel
  # Prints a +message+ with timestamp to stdout.
  def log(message)
    Kicker::Utils.log(message)
  end
  
  # Executes the +command+, logs the output, and optionally growls.
  def execute(command, &block)
    Kicker::Utils.execute(command, &block)
  end
  
  # Returns the last executed command.
  def last_command
    Kicker::Utils.last_command
  end
end
