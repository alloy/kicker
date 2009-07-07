Kicker.option_parser.on('-e', '--execute [COMMAND]', 'The command to execute.') do |command|
  Kicker.process_callback = lambda do |files|
    files.clear
    Kicker.execute_command "sh -c #{command.inspect}"
  end
end