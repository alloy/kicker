Kicker.process_callback = lambda do |kicker, files|
  kicker.log('')
  kicker.log("Could not handle: #{files.join(', ')}")
  kicker.log('')
end