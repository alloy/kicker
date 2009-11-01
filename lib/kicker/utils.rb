class Kicker
  module Utils #:nodoc:
    extend self
    
    attr_accessor :ruby_bin_path
    self.ruby_bin_path = 'ruby'
    
    def execute(command)
      @last_command = command
      
      log "Change occured, executing command: #{command}"
      Kicker.growl(GROWL_NOTIFICATIONS[:change], 'Kicker: Change occured, executing command:', command) if Kicker.use_growl
      
      output = `#{command}`
      output.strip.split("\n").each { |line| log "  #{line}" }
      
      log "Command #{last_command_succeeded? ? 'succeeded' : "failed (#{last_command_status})"}"
      
      if Kicker.use_growl
        if last_command_succeeded?
          callback = Kicker.growl_command.nil? ? GROWL_DEFAULT_CALLBACK : lambda { system(Kicker.growl_command) }
          Kicker.growl(GROWL_NOTIFICATIONS[:succeeded], "Kicker: Command succeeded", output, &callback)
        else
          Kicker.growl(GROWL_NOTIFICATIONS[:failed], "Kicker: Command failed (#{last_command_status})", output, &GROWL_DEFAULT_CALLBACK)
        end
      end
    end
    
    def last_command
      @last_command
    end
    
    def log(message)
      puts "[#{Time.now}] #{message}"
    end
    
    def run_ruby_tests(tests)
      execute "#{ruby_bin_path} -r #{tests.join(' -r ')} -e ''" unless tests.empty?
    end
    
    private
    
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