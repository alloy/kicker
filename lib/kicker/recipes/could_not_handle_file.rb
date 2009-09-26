post_process_callback do |files|
  log('')
  log("Could not handle: #{files.join(', ')}")
  log('')
end