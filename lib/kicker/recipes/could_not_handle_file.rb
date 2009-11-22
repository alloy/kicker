post_process do |files|
  unless Kicker.silent?
    log('')
    log("Could not handle: #{files.join(', ')}")
    log('')
  end
end