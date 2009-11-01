class Kicker
  module Utils #:nodoc:
    extend self
    
    def execute(command)
      @last_command = command
      
      log "Change occured, executing command: #{command}"
      Kicker::Growl.change_occured(command) if Kicker::Growl.use?
      
      output = `#{command}`
      
      log_result(output)
      Kicker::Growl.result(output) if Kicker::Growl.use?
    end
    
    def last_command
      @last_command
    end
    
    def log(message)
      puts "[#{Time.now}] #{message}"
    end
    
    def run_ruby_tests(tests)
      execute "ruby -r #{tests.join(' -r ')} -e ''" unless tests.empty?
    end
    
    def last_command_succeeded?
      $?.success?
    end
    
    def last_command_status
      $?.to_i
    end
    
    private
    
    def log_result(output)
      output.strip.split("\n").each { |line| log "  #{line}" }
      log "Command #{last_command_succeeded? ? 'succeeded' : "failed (#{last_command_status})"}"
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