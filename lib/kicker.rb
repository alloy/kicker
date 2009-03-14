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
    validate_path_and_command!
    validate_path_exists!
  end
  
  def validate_path_and_command!
    unless @path && @command
      puts "Usage: #{$0} [PATH] [COMMAND]"
      exit
    end
  end
  
  def validate_path_exists!
    unless File.exist?(@path)
      puts "The given path `#{@path}' does not exist."
      exit 1
    end
  end
end