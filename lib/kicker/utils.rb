class Kicker
  private
  
  def log(message)
    puts "[#{Time.now}] #{message}"
  end
  
  def last_command_succeeded?
    $?.success?
  end
  
  def last_command_status
    $?.to_i
  end
end