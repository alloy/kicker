options.on('-e', '--execute [COMMAND]', 'The command to execute.') do |command|
  callback = lambda do |files|
    files.clear
    execute "sh -c #{command.inspect}"
  end

  startup callback
  pre_process callback
end
