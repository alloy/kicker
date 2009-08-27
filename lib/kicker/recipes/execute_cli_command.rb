Kicker.option_parser.on('-e', '--execute [COMMAND]', 'The command to execute.') do |command|
  Kicker.process_callback = lambda do |kicker, files|
    files.clear
    kicker.execute_command "sh -c #{command.inspect}"
  end
end