class Kicker
  attr_accessor :path, :command
  
  def initialize(options)
    @path = options[:path]
    @command = options[:command]
  end
  
  def start
    validate_options!
  end
  
  private
  
  def validate_options!
    unless @path && @command
      puts "Usage: #{$0} [PATH] [COMMAND]"
      exit
    end
  end
end