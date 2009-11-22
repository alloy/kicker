class Kicker
  module Utils #:nodoc:
    extend self
    
    attr_accessor :ruby_bin_path
    self.ruby_bin_path = 'ruby'
    
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
      now = Time.now
      puts "#{now.strftime('%H:%M:%S')}.#{now.usec.to_s[0,2]} | #{message}"
    end
    
    def run_ruby_tests(tests)
      execute "#{ruby_bin_path} -r #{tests.join(' -r ')} -e ''" unless tests.empty?
    end
    
    def last_command_succeeded?
      $?.success?
    end
    
    def last_command_status
      $?.to_i
    end
    
    private
    
    def will_execute_command(status)
      log(status.call(:stdout) || "Executing: #{status.command}")
      Kicker::Growl.change_occured(status.command) if Kicker::Growl.use? && !Kicker.silent?
    end
    
    def did_execute_command(status)
      unless message = status.call(:stdout)
        if status.success? && Kicker.silent?
          message = 'Success'
        else
          puts "\n#{status.output.strip}\n\n"
          message = status.success? ? "Success" : "Failed (#{status.exit_code})"
        end
      end
      log message
      
      Kicker::Growl.result(status.output) if Kicker::Growl.use?
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
  
  # A convenience method that takes an array of Ruby test files and runs them
  # collectively.
  def run_ruby_tests(tests)
    Kicker::Utils.run_ruby_tests(tests)
  end
end