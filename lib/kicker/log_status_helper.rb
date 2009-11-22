class Kicker
  class LogStatusHelper
    attr_reader :command, :output
    
    def initialize(proc, command)
      @proc, @command, @output, @success = proc, command
    end
    
    def result(output, success)
      @output, @success = output, success
    end
    
    def call(logger_type)
      @logger_type = logger_type
      @proc.call(self) if @proc
    end
    
    def stdout?
      @logger_type == :stdout
    end
    
    def growl?
      @logger_type == :growl
    end
    
    def before?
      @output.nil?
    end
    
    def after?
      !before?
    end
    
    def success?
      @success
    end
  end
end