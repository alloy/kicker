class Kicker
  def log(message)
    self.class.log(message)
  end
  
  def execute_command(command)
    self.class.execute_command(command)
  end
  
  class << self
    def execute_command(command)
      log "Change occured, executing command: #{command}"
      growl(GROWL_NOTIFICATIONS[:change], 'Kicker: Change occured, executing command:', command) if use_growl
      
      output = `#{command}`
      output.strip.split("\n").each { |line| log "  #{line}" }
      
      log "Command #{last_command_succeeded? ? 'succeeded' : "failed (#{last_command_status})"}"
      
      if use_growl
        if last_command_succeeded?
          callback = growl_command.nil? ? GROWL_DEFAULT_CALLBACK : lambda { system(growl_command) }
          growl(GROWL_NOTIFICATIONS[:succeeded], "Kicker: Command succeeded", output, &callback)
        else
          growl(GROWL_NOTIFICATIONS[:failed], "Kicker: Command failed (#{last_command_status})", output, &GROWL_DEFAULT_CALLBACK)
        end
      end
    end
    
    def log(message)
      puts "[#{Time.now}] #{message}"
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