class Kicker
  module Utils #:nodoc:
    extend self
    
    def execute(command, &block)
      @last_command = command
      status = LogStatusHelper.new(block, command)
      
      will_execute_command(status)
      status.result(`#{command}`, last_command_succeeded?, last_command_status)
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
    
    def will_execute_command(status)
      message = status.call(:stdout) || "Executing: #{status.command}"
      log(message) unless message.empty?
      Kicker::Growl.change_occured(status) if Kicker::Growl.use? && !Kicker.silent?
    end
    
    def did_execute_command(status)
      if message = status.call(:stdout)
        log(message) unless message.empty?
      else
        if status.success? && Kicker.silent?
          log 'Success'
        else
          puts("\n#{status.output.strip}\n\n")
          log(status.success? ? "Success" : "Failed (#{status.exit_code})")
        end
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