post_process do |files|
  log('')
  log("Could not handle: #{files.join(', ')}")
  log('')
end