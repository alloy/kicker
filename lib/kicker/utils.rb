class Kicker
  module Utils #:nodoc:
    extend self
    
    def execute(command)
      @last_command = command
      change_occured(command)
      
      output = `#{command}`
      
      log_result(output)
      growl_result(output)
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
    
    private
    
    def log_result(output)
      output.strip.split("\n").each { |line| log "  #{line}" }
      log "Command #{last_command_succeeded? ? 'succeeded' : "failed (#{last_command_status})"}"
    end
    
    def change_occured(command)
      log "Change occured, executing command: #{command}"
      if Kicker.use_growl
        Kicker.growl(GROWL_NOTIFICATIONS[:change], 'Kicker: Change occured, executing command:', command)
      end
    end
    
    def growl_result(output)
      if Kicker.use_growl
        last_command_succeeded? ? growl_succeeded(output) : growl_failed(output)
      end
    end
    
    def growl_command
      lambda { system(Kicker.growl_command) } if Kicker.growl_command
    end
    
    def growl_succeeded(output)
      callback = growl_command || GROWL_DEFAULT_CALLBACK
      Kicker.growl(GROWL_NOTIFICATIONS[:succeeded], "Kicker: Command succeeded", output, &callback)
    end
    
    def growl_failed(output)
      message = "Kicker: Command failed (#{last_command_status})"
      Kicker.growl(GROWL_NOTIFICATIONS[:failed], message, output, &GROWL_DEFAULT_CALLBACK)
    end
    
    def last_command_succeeded?
      $?.success?
    end
    
    def last_command_status
      $?.to_i
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