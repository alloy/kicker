Kicker.option_parser.on('-e', '--execute [COMMAND]', 'The command to execute.') do |command|
  Kicker.pre_process_callback = lambda do |files|
    files.clear
    execute "sh -c #{command.inspect}"
  end
end
