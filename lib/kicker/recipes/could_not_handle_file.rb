Kicker.post_process_callback = lambda do |files|
  Kicker.log('')
  Kicker.log("Could not handle: #{files.join(', ')}")
  Kicker.log('')
end