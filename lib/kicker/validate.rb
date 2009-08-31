class Kicker
  private
  
  def validate_options!
    validate_paths_and_command!
    validate_paths_exist!
  end
  
  def validate_paths_and_command!
    if process_chain.empty? && pre_process_chain.empty?
      puts OPTION_PARSER_CALLBACK.call(nil).help
      exit
    end
  end
  
  def validate_paths_exist!
    @paths.each do |path|
      unless File.exist?(path)
        puts "The given path `#{path}' does not exist"
        exit 1
      end
    end
  end
end
