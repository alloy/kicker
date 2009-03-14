class Kicker
  attr_reader :path, :command
  
  def initialize(options)
    @path = options[:path]
    @command = options[:command]
  end
end