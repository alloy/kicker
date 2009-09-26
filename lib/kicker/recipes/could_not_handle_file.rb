Kicker.post_process_callback = lambda do |files|
  log('')
  log("Could not handle: #{files.join(', ')}")
  log('')
end