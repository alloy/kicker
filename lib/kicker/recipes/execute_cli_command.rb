class Kicker
  PARSER.on('-e', '--execute [COMMAND]', 'The command to execute.') do |command|
    callback_chain.append_callback lambda { |kicker, _|
      kicker.execute_command "sh -c #{command.inspect}"
    }
  end
end