class Kicker
  module Utils #:nodoc:
    extend self
    
    def execute(command, &block)
      @last_command = command
      status = LogStatusHelper.new(block, command)
      will_execute_command(status)

      puts unless Kicker.silent?
      $stdout.sync = true
      output = ""
      IO.popen(command) do |stdout|
        while str = stdout.read(1)
          output << str
          $stdout.print str unless Kicker.silent?
        end
      end
      $stdout.sync = false
      puts("\n\n") unless Kicker.silent?

      status.result(output, last_command_succeeded?, last_command_status)
      did_execute_command(status)
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
      $?.to_i
    end
    
    private
    
    CLEAR = "\e[H\e[2J"
    
    def will_execute_command(status)
      puts(CLEAR) if Kicker.clear_console?
      message = status.call(:stdout) || "Executing: #{status.command}"
      log(message) unless message.empty?
      Kicker::Growl.change_occured(status) if Kicker::Growl.use? && !Kicker.silent?
    end
    
    def did_execute_command(status)
      if message = status.call(:stdout)
        log(message) unless message.empty?
      else
        puts("\n#{status.output.strip}\n\n") if Kicker.silent? && !status.success?
        log(status.success? ? "Success" : "Failed (#{status.exit_code})")
      end
      
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
