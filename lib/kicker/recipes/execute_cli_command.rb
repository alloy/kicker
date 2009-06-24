class Kicker
  PARSER.on('-e', '--execute [COMMAND]', 'The command to execute.') do |command|
    Kicker.callback = lambda do |kicker, _|
      kicker.execute_command "sh -c #{command.inspect}"
    end
  end
end