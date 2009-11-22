class Kicker
  module Utils #:nodoc:
    extend self
    
    attr_accessor :ruby_bin_path
    self.ruby_bin_path = 'ruby'
    
    def execute(command)
      @last_command = command
      will_execute_command(command)
      output = `#{command}`
      did_execute_command(output)
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
    
    def will_execute_command(command)
      log "Executing: #{command}"
      Kicker::Growl.change_occured(command) if Kicker::Growl.use? && !Kicker.silent?
    end
    
    def did_execute_command(output)
      Kicker::Growl.result(output) if Kicker::Growl.use?
      
      if last_command_succeeded? && Kicker.silent?
        log 'Success'
      else
        output.strip.split("\n").each { |line| log "  #{line}" }
        log(last_command_succeeded? ? 'Success' : "Failed (#{last_command_status})")
      end
    end
  end
end

module Kernel
  # Prints a +message+ with timestamp to stdout.
  def log(message)
    Kicker::Utils.log(message)
  end
  
  # Executes the +command+, logs the output, and optionally growls.
  def execute(command)
    Kicker::Utils.execute(command)
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